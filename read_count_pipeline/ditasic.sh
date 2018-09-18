#!/bin/bash

### Testing on 12 samples

# Generate the similarity matrix of the 4 reference files.
# creates Kallisto ref as "kalindex_4ref"

ditasic_matrix.py -l 1000 -o output/similarity_matrix4.npy data/reference_paths --startprob 0.1 --avgprob 0.05 --endprob 0.1

# runs from 1 to 12
COUNTER=1
while [ $COUNTER -lt 13 ]; do
  echo Processing sample $COUNTER
  # Map the samples to the reference files for the raw abundance values
  ditasic_mapping.py -l 1000 -i kalindex_4ref data/reference_paths data/samples_filtered/${COUNTER}.fastq
  # Move values to output
  mv ${COUNTER}_mapped_counts.npy ${COUNTER}_total.npy output
  # Estimate abundance for sample
  ditasic -r data/reference_paths -a output/similarity_matrix4.npy \
                  -x output/${COUNTER}_mapped_counts.npy -n output/${COUNTER}_total.npy \
                  -f F -t 750 -o output/${COUNTER}_abundance.txt
  let COUNTER=COUNTER+1
done
