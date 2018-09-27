#!/bin/bash

if [ ! -d "working/samples_filtered/" ]; then
  mkdir working/samples_filtered
fi

if [ ! -d "output/" ]; then
  mkdir output
fi

TAB=$'\t'

for sample in data/samples_unfiltered/*.fastq; do
  sample_name=$(basename $sample .fastq)
  echo "Processing $sample"
  if [ -f "output/${sample_name}.tsv" ]; then
    echo "$sample already processed"
    continue
  fi
  # filter reads for each sample
  serum_readfilter runfilter kraken -db working/kraken_db -R1 $sample -R2 $sample -t 4
  rm filtered_R2.fastq
  mv filtered_R1.fastq "working/samples_filtered/${sample_name}.fastq"

  # Map the samples to the reference files for the raw abundance values
  ditasic_mapping.py -l 1000 -i kalindex_* working/reference_paths.txt "working/samples_filtered/${sample_name}.fastq"

  # Move values to output
  mv "${sample_name}_mapped_counts.npy" "${sample_name}_total.npy" working

  # Estimate abundance for sample
  ditasic -r working/reference_paths.txt -a working/similarity_matrix.npy \
                  -x "working/${sample_name}_mapped_counts.npy" -n "working/${sample_name}_total.npy" \
                  -f F -t 750 -o "output/${sample_name}.tsv"

  # Add sample label to output .tsv
  output="output/${sample_name}.tsv"
  sed -i '' 's/$/'"${TAB}${sample_name}"'/' $output
  sed -i '' '1d' $output
done

echo $'taxa.name\tcount.estimate\terror.estimate\tfiltered\traw.pval\tsample' > temp/header.txt
cat temp/header.txt output/*.tsv > output.tsv
