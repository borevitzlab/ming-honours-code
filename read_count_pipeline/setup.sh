#!/bin/bash

# Create intermediate directory
if [ ! -d "working/" ]; then
  echo "[setup] Creating intermediate files folder ..."
  mkdir working/
fi

# Before setup, place ref genomes in ref_genomes
# Create read filter database

echo "[setup] Checking kraken database ..."
if [ ! -d "working/kraken_db/" ]; then
  echo "[setup] Kraken db not found! Creating kraken database ..."
  serum_readfilter makedb kraken -db working/kraken_db/ -ref data/ref_genomes/
fi

# Index paths to reference genomes
if [ ! -f working/reference_paths.txt ]; then
  echo "[setup] Indexing reference genome paths ..."
  for genome in data/ref_genomes/*.fasta; do
      echo $genome >> working/reference_paths.txt
  done
fi

# Generate the similarity matrix of the reference files.
# creates Kallisto ref as "kalindex<number of reference genomes>_ref"

echo "[setup] Creating ditasic similarity matrix"
ditasic_matrix.py -l 1000 -o output/similarity_matrix.npy working/reference_paths.txt --startprob 0.1 --avgprob 0.05 --endprob 0.1
