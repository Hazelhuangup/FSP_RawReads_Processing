
/*
 * Step 5: collect statistics of each step
 */

process fqStat {

    tag "$sample_ID"

    publishDir("${params.OutDir}/02_Trimmed_reads/${params.Batch_ID}/00_statistics", mode: 'copy')

    input:
	tuple val(sample_ID), path(fastq_files)

    output:
	path "${sample_ID}*stats"

    script:
    """
    for fq in ${fastq_files}; do
        zcat "\$fq" | fq_n50.pl > "${sample_ID}_\$(basename "\$fq").stats"
    done
    """
}
