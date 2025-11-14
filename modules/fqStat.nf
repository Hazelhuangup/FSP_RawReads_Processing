
/*
 * Step 5: collect statistics of each step
 */

process fqStat {

    tag "$sample_ID"

    publishDir("${params.OutDir}/02_Trimmed_reads/${params.Batch_ID}/00_statistics", mode: 'copy')

    input:
    tuple val(sample_ID), path(fastp_dir)

    output:
	path "${sample_ID}*stats"

    script:
    """
    for fq in ${fastp_dir}/${sample_ID}*.gz; do
        zcat \$fq | fq_n50.pl > \$(basename \$fq).stats
    done
    """
}
