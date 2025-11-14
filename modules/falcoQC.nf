/*
 * Step 1: falcoQC of raw reads, export falcoQC report
 */

process falcoQC {

	tag "$sample_ID"  //assign a custom label to each task execution

	publishDir("${params.OutDir}/01_ReadQC_report/${params.Batch_ID}/raw_reads_QC", mode: 'copy')

	input:
		val sample_ID

	output:
		path "${sample_ID}"

	script:
	"""
		falco --outdir "${sample_ID}" ${params.InDir}/${sample_ID}/*gz
	"""
}
