#!/bin/bash

# Usage: ./sim_maker.sh <number of reads per reference genome>

per_sample="$1"

for f in data/ref_genomes/*.fasta; do
  echo "Simulating from $f"
  sample_name=$(basename $f .fasta)
  nanosim-h -o $sample_name -p ecoli_R9_1D -n $per_sample --max-len 50000 $f
  rm $sample_name.errors.txt
  rm $sample_name.log
  cat $sample_name.fa >> $sample_name.fasta
  rm $sample_name.fa
  echo "Converting to fake fastq"
  reformat.sh in=$sample_name.fasta out=$sample_name.temp.fastq qfake=20
  echo "Writing to data/samples_unfiltered/$sample_name.fastq"
  sed 's/-/ /g' $sample_name.temp.fastq > data/samples_unfiltered/$sample_name.fastq
  rm $sample_name.fasta
  rm $sample_name.temp.fastq
done

echo "Done!"
