#!/bin/bash

echo "Starting job on $HOSTNAME"

INPUT_DIR=/mnt/shared/projects/rbgk/projects/FSP/03_Output/01_QC/02_Trimmed_reads/XX

cd ${INPUT_DIR}
mkdir -p z_states_for_spreadsheet

#while read i;do 
#	for a in `ls $i/*gz`; do 
#		rename -d ast *fastq*
#		zcat $a |awk 'NR%4==2 {sum += length($0)} END {print sum}' ;
#		zcat $a |fq_n50.pl > $a.stats
#	done;
#done < /mnt/shared/projects/rbgk/projects/FSP/00_RawData/01_SeqData/XX/sample.list

grep 'Total' */*merge.fq.gz.stats> z_states_for_spreadsheet/total_bp_merged.txt
grep 'Total' */*trimmed*.fq.gz.stats> z_states_for_spreadsheet/total_bp_trimmed.txt
grep 'Average' */*merge.fq.gz.stats> z_states_for_spreadsheet/Len_avg_merged.txt

echo "Job finished"
