#!/bin/bash

#SBATCH --job-name=QC_NF
#SBATCH --export=ALL
#SBATCH --partition=medium
#SBATCH --output=QC_MAIN.log
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G

# check if a BATCH_ID is set
if [ -z "$BATCH_ID" ]; then
  echo "Error: BATCH_ID not set. Usage: sbatch --export=BATCH_ID=<Batch_ID> ReadQC.sh"
  exit 1
fi

source /mnt/apps/users/whuang/conda/etc/profile.d/conda.sh
conda activate nf

nextflow run ReadQC.nf -profile cropdiv_hpc -resume \
	--InDir /mnt/shared/projects/rbgk/projects/FSP/00_RawData/01_SeqData/"${BATCH_ID}" \
	--OutDir /mnt/shared/projects/rbgk/projects/FSP/03_Output/01_QC \
	--Li /mnt/shared/projects/rbgk/projects/FSP/00_RawData/01_SeqData/"${BATCH_ID}"/sample.list \
	--Batch_ID "${BATCH_ID}"

#nextflow run ReadQC.nf -profile cropdiv_hpc -resume \
#	--InDir /mnt/shared/projects/rbgk/projects/FSP/00_RawData/03_TestData/"${BATCH_ID}" \
#	--OutDir /mnt/shared/projects/rbgk/projects/FSP/00_RawData/03_TestData/04_Simulated_raw_reads_to_clean \
#	--Li /mnt/shared/projects/rbgk/projects/FSP/00_RawData/03_TestData/"${BATCH_ID}"/sample.list \
#	--Batch_ID "${BATCH_ID}"

sed 's/XX/"${BATCH_ID}"/g' ./bin/fq_stats.sh | sh
sed 's/XX/"${BATCH_ID}"/g' ./bin/kmer_stats.sh | sh
cp /mnt/shared/projects/rbgk/projects/FSP/02_src/01_QC/00_nf_QC/bin/fastQC_result_compiling.sh /mnt/shared/projects/rbgk/projects/FSP/03_Output/01_QC/01_ReadQC_report/"${BATCH_ID}"/after_fastp_QC
cp /mnt/shared/projects/rbgk/projects/FSP/02_src/01_QC/00_nf_QC/bin/fastQC_result_compiling.sh /mnt/shared/projects/rbgk/projects/FSP/03_Output/01_QC/01_ReadQC_report/"${BATCH_ID}"/raw_reads_QC
cd /mnt/shared/projects/rbgk/projects/FSP/03_Output/01_QC/01_ReadQC_report/"${BATCH_ID}"/after_fastp_QC/ && sh fastQC_result_compiling.sh
cd /mnt/shared/projects/rbgk/projects/FSP/03_Output/01_QC/01_ReadQC_report/"${BATCH_ID}"/raw_reads_QC/ && fastQC_result_compiling.sh
