#!/bin/bash

set -euo pipefail

echo "Starting job on $HOSTNAME"

INPUT_DIR=/mnt/shared/projects/rbgk/projects/FSP/03_Output/01_QC/05_KmerAnalysis/07_2025.10.01_EdGen_03_244_samples
OUT_DIR="$INPUT_DIR/statistics"
OUT_CSV="$OUT_DIR/statistics_all.csv"
PEAK_CSV="$OUT_DIR/kmer_hist_peak_auto_classification.csv"

mkdir -p "$OUT_DIR"

source /mnt/apps/users/whuang/conda/etc/profile.d/conda.sh
conda activate bioinfo

kmer_hist_peak_auto_classification.py \
	-f "$INPUT_DIR" \
	-o "$PEAK_CSV"

kmer_stats_collect.py \
	--input-dir "$INPUT_DIR" \
	--peak-csv "$PEAK_CSV" \
	--out-csv "$OUT_CSV"

statistics_summary_extract.py \
	"$OUT_CSV" \
	-o "$OUT_DIR/kmer_profile_statistics_automated.csv"

rm "$PEAK_CSV"
echo "Job finished"
