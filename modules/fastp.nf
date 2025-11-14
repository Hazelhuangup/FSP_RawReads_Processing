/*
 * Step 2: Trimming and merge the raw reads, export trimmed and merged reads
 */

process fastp {

    tag "$sample_ID"

    publishDir("${params.OutDir}/02_Trimmed_reads/${params.Batch_ID}", mode: 'copy')

    input:
    val sample_ID

    output:
	tuple val(sample_ID), path("${sample_ID}")

    script:
    """
    mkdir -p ${sample_ID}

    fastp \\
        -i ${params.InDir}/${sample_ID}/*1.*.gz \\
        -o ${sample_ID}/${sample_ID}_trimmed.R1.fq.gz \\
        -I ${params.InDir}/${sample_ID}/*2.*.gz \\
        -O ${sample_ID}/${sample_ID}_trimmed.R2.fq.gz \\
        -w 6 \\
		-l 30 \\
		--detect_adapter_for_pe \\
		--poly_g_min_len 8 \\
		--trim_front1 2 \\
        --adapter_fasta /mnt/shared/projects/rbgk/projects/FSP/01_RefSeq/01_adapters/Illumina_adapter.fa \\
        --dedup \\
		-W 3 -5 -3 \\
		--low_complexity_filter 15
		${params.FP_args}

    fastp \\
        -i ${sample_ID}/${sample_ID}_trimmed.R1.fq.gz \\
        -o ${sample_ID}/${sample_ID}_unmerged.R1.fq.gz \\
        -I ${sample_ID}/${sample_ID}_trimmed.R2.fq.gz \\
        -O ${sample_ID}/${sample_ID}_unmerged.R2.fq.gz \\
        --merge \\
        --merged_out ${sample_ID}/${sample_ID}_merge.fq.gz \\
		-l 30 \\
        --overlap_len_require 20 \\
		--overlap_diff_limit 2
		${params.FP_args}
    """
}
