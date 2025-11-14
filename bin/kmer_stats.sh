#!/bin/bash

echo "Starting job on $HOSTNAME"

INPUT_DIR=/mnt/shared/projects/rbgk/projects/FSP/03_Output/01_QC/05_KmerAnalysis/XX

cd ${INPUT_DIR}

grep 'Est_genome_size' */*kmer_freq.stats >Est_genome_size.txt
grep 'peak' */*kmer_freq.stats >peak.txt
grep 'nkmer' */*kmer_freq.stats >nkmer.txt
tail -q -n 1 */*distinct_kmers.hist > distinct_kmers.txt

mkdir -p statistics
mv *txt statistics

echo "Job finished"
