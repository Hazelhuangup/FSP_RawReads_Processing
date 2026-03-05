/*
 * Step 4: Kmer analysis of the trimmed and merged reads
 */

process kmerAnalysis {

    tag "$sample_ID"

    publishDir("${params.OutDir}/05_KmerAnalysis/${params.Batch_ID}/${sample_ID}", mode: 'copy')

    input:
    tuple val(sample_ID), path(fastq_files)

    output:
    path("${sample_ID}.reads.kmer_freq.hist")
    path("${sample_ID}*.log"), emit: done
    path("peak_1")
    path("peak_2")

    script:
    """
    R1=""
    R2=""

    for fq in ${fastq_files}; do
        fq_base=\$(basename "\$fq")
        if [[ "\$fq_base" == "${sample_ID}_trimmed.R1.fq.gz" ]]; then
            R1="\$fq"
        elif [[ "\$fq_base" == "${sample_ID}_trimmed.R2.fq.gz" ]]; then
            R2="\$fq"
        fi
    done

    if [[ -z "\$R1" || -z "\$R2" ]]; then
        echo "Cannot find trimmed read pairs for sample ${sample_ID}" >&2
        echo "Found files: ${fastq_files}" >&2
        exit 1
    fi

    FastK -k17 -T${task.cpus} -v -M8 -N${sample_ID} ${params.KA_args} \$R1 \$R2 1>${sample_ID}.fastK.log 2>&1
    Histex -G ${sample_ID}.hist > ${sample_ID}.reads.kmer_freq.hist

    genomescope.R -i ${sample_ID}.reads.kmer_freq.hist -o peak_1 -p 1 -k 17 >${sample_ID}.genomescope.log
    genomescope.R -i ${sample_ID}.reads.kmer_freq.hist -o peak_2 -p 2 -k 17 >>${sample_ID}.genomescope.log

    """
}
