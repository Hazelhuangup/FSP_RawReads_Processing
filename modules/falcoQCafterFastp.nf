/*
 * Step 3: falcoQC of trimmed reads, export falcoQC report
 */

process falcoQCafterFastp {

	tag "$sample_ID"  //assign a custom label to each task execution

	publishDir("${params.OutDir}/01_ReadQC_report/${params.Batch_ID}/after_fastp_QC", mode: 'copy')

	input:
		tuple val(sample_ID), path(fastp_dir)

	output:
		path "${sample_ID}/*txt"
		path "${sample_ID}/*html"

	script:
	"""
	falco --outdir "${sample_ID}" ${fastp_dir}/*gz
	"""
}
