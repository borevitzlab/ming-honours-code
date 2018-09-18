# runs from 1 to 12
COUNTER=1
while [ $COUNTER -lt 13 ]; do
  echo Processing sample $COUNTER
  serum_readfilter runfilter kraken -db data/kraken_db -R1 data/samples_unfiltered/${COUNTER}.fastq -R2 data/samples_unfiltered/${COUNTER}.fastq -t 4
  rm -rf filtered_R2.fastq
  mv filtered_R1.fastq data/samples_filtered/${COUNTER}.fastq
  let COUNTER=COUNTER+1
done

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

for sample in 
