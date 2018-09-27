#!/bin/bash

echo 'sample, before, after' > read_filter_counts.csv

for sample in data/samples_unfiltered/*.fastq; do
  sample_name=$(basename $sample .fastq)
  # counting from https://www.biostars.org/p/139006/#139009
  before=$(awk '{s++}END{print s/4}' $sample)
  after=$(awk '{s++}END{print s/4}' working/samples_filtered/${sample_name}.fastq)
  echo $sample_name,$before,$after >> read_filter_counts.csv
done
