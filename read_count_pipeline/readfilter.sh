#!/bin/bash

# if not already done, make Kraken db
#serum_readfilter makedb kraken -db kraken_db -ref ref_genomes/

# filter reads

# runs from 1 to 12
COUNTER=1
while [ $COUNTER -lt 13 ]; do
  echo Processing sample $COUNTER
  serum_readfilter runfilter kraken -db data/kraken_db -R1 data/samples_unfiltered/${COUNTER}.fastq -R2 data/samples_unfiltered/${COUNTER}.fastq -t 4
  rm -rf filtered_R2.fastq
  mv filtered_R1.fastq data/samples_filtered/${COUNTER}.fastq
  let COUNTER=COUNTER+1
done
