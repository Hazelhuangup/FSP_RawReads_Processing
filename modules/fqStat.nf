
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


process fqStatSummary {

    publishDir("${params.OutDir}/02_Trimmed_reads/${params.Batch_ID}/00_statistics", mode: 'copy')

    input:
    path(stats_files)

    output:
    path("z_states_for_spreadsheet/*txt")

    script:
    """
    mkdir -p z_states_for_spreadsheet

    for stat in ${stats_files}; do
        stat_base=\$(basename "\$stat")

        if [[ "\$stat_base" == *merge.fq.gz.stats ]]; then
            grep 'Total' "\$stat" >> z_states_for_spreadsheet/total_bp_merged.txt
            grep 'Average' "\$stat" >> z_states_for_spreadsheet/Len_avg_merged.txt
        fi

        if [[ "\$stat_base" == *trimmed*.fq.gz.stats ]]; then
            grep 'Total' "\$stat" >> z_states_for_spreadsheet/total_bp_trimmed.txt
        fi
    done
    """
}
