/*
 * Step 4: Kmer analysis of the trimmed and merged reads
 */

process kmerAnalysis {

    tag "$sample_ID"

    publishDir("${params.OutDir}/05_KmerAnalysis/${params.Batch_ID}/${sample_ID}", mode: 'copy')

    input:
    tuple val(sample_ID), path(fastp_dir)

    output:
    path("${sample_ID}*kmer*")

    script:
    """
    yak-count -k 17 -b 20 ${fastp_dir}/${sample_ID}_merge.fq.gz 1>${sample_ID}.reads.kmer_freq.hist 2>${sample_ID}.log

    awk '{sum+=\$1*\$2}END{printf "nkmer: %.0f\\n", sum}' ${sample_ID}.reads.kmer_freq.hist > ${sample_ID}.reads.kmer_freq.stats
    awk 'NR>=6 {if (\$2 > max) {max=\$2; value=\$1}} END {print "peak: " value}' ${sample_ID}.reads.kmer_freq.hist >> ${sample_ID}.reads.kmer_freq.stats
    awk 'NR==1 {a=\$2} NR==2 {b=\$2} END {print "Est_genome_size:",int(a/b)}' ${sample_ID}.reads.kmer_freq.stats >> ${sample_ID}.reads.kmer_freq.stats

    head -n 250 ${sample_ID}.reads.kmer_freq.hist > ${sample_ID}.250.kmer_freq.hist
    tail -n +251 ${sample_ID}.reads.kmer_freq.hist | awk '{sum += 1}END{print ">250",sum}' >> ${sample_ID}.250.kmer_freq.hist
    kmer_freq_draw.py ${sample_ID}.250.kmer_freq.hist ${sample_ID}.reads.kmer_freq.hist.pdf

	echo -n "${sample_ID}" > distinct_kmers.hist
	grep "processed" ${sample_ID}.log|tail -1| awk '{print \$5}' >${sample_ID}.distinct_kmers.hist
	draw_distinct_kmer_vs_reads.py ${sample_ID}.distinct_kmers.hist

    """
}
