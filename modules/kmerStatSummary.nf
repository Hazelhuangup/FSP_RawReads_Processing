/*
 * Step 4b: collect kmer statistics of the whole batch
 */

process kmerStatSummary {

    publishDir("${params.OutDir}/05_KmerAnalysis/${params.Batch_ID}", mode: 'copy')

    input:
    path(done_logs)

    output:
    path("statistics/statistics_all.csv")
    path("statistics/kmer_profile_statistics_automated.csv")

    script:
    """
    INPUT_DIR="${params.OutDir}/05_KmerAnalysis/${params.Batch_ID}"
    OUT_DIR="statistics"
    OUT_CSV="\$OUT_DIR/statistics_all.csv"
    PEAK_CSV="\$OUT_DIR/kmer_hist_peak_auto_classification.csv"

    mkdir -p "\$OUT_DIR"

    python ${projectDir}/bin/kmer_hist_peak_auto_classification.py \
        -f "\$INPUT_DIR" \
        -o "\$PEAK_CSV"

    python ${projectDir}/bin/kmer_stats_collect.py \
        --input-dir "\$INPUT_DIR" \
        --peak-csv "\$PEAK_CSV" \
        --out-csv "\$OUT_CSV"

    python ${projectDir}/bin/statistics_summary_extract.py \
        "\$OUT_CSV" \
        -o "\$OUT_DIR/kmer_profile_statistics_automated.csv"

    rm "\$PEAK_CSV"
    """
}
