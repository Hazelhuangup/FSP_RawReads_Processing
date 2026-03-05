/*
 * Step 3: falcoQC of trimmed reads, export falcoQC report
 */

process falcoQCafterFastp {

	tag "$sample_ID"  //assign a custom label to each task execution

	publishDir("${params.OutDir}/01_ReadQC_report/${params.Batch_ID}/after_fastp_QC", mode: 'copy')

	input:
		tuple val(sample_ID), path(fastq_files)

	output:
		path "${sample_ID}"

	script:
	"""
	mkdir -p ${sample_ID}
	falco --outdir "${sample_ID}" ${fastq_files}
	"""
}
