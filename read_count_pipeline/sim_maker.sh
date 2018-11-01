#!/bin/bash

# Usage: ./sim_maker.sh <number of reads per reference genome> <output file prefix>

per_sample="$1"
outfile="$2"

for f in data/ref_genomes/*.fasta; do
  echo "Simulating from $f"
  sample_name=$(basename $f .fasta)
  nanosim-h -o $sample_name -p ecoli_R9_1D -n $per_sample --max-len 50000 $f
  rm $sample_name.errors.txt
  rm $sample_name.log
  cat $sample_name.fa >> $outfile.fasta
  rm $sample_name.fa
done

echo "Converting to fake fastq"
reformat.sh in=$outfile.fasta out=$outfile.temp.fastq qfake=20
sed 's/-/ /g' $outfile.temp.fastq > data/samples_unfiltered/$outfile.fastq
echo "Written to data/samples_unfiltered/$outfile.fastq"

rm $outfile.fasta
rm $outfile.temp.fastq

echo "Done!"
