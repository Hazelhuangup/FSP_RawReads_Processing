/*
 * Step 1/3 summary: compile Falco QC metrics to exportable txt table
 */

process falcoQCstatCompiling {

    tag "$qc_subdir"

    publishDir("${params.OutDir}/01_ReadQC_report/${params.Batch_ID}/${qc_subdir}", mode: 'copy')

    input:
    tuple val(qc_subdir), path(falco_dirs)

    output:
    path("fastQC_result.txt")

    script:
    """
    for dir in ${falco_dirs}; do
        grep 'Filename' "\$dir"/*fastqc_data.txt
    done | awk '{split(\$2,a,".");print a[1]}' > name.txt

    for dir in ${falco_dirs}; do
        grep '%GC' "\$dir"/*fastqc_data.txt
    done | awk '{print \$2}' > GC.txt

    for dir in ${falco_dirs}; do
        grep 'Total Sequences' "\$dir"/*fastqc_data.txt
    done | awk '{print \$3}' > total_reads_no.txt

    for dir in ${falco_dirs}; do
        grep 'Total Deduplicated Percentage' "\$dir"/*fastqc_data.txt
    done | awk '{print 100-\$4}' > duplication_level.txt

    for dir in ${falco_dirs}; do
        grep 'Per sequence GC content' "\$dir"/*gz_summary.txt
    done | awk '{print \$1}' > GC_pass.txt

    echo -e "name\tGC\tGC_pass\ttotal_reads_no\tDuplicated Percentage" > fastQC_result.txt
    paste name.txt GC.txt GC_pass.txt total_reads_no.txt duplication_level.txt >> fastQC_result.txt

    rm name.txt GC.txt GC_pass.txt total_reads_no.txt duplication_level.txt
    """
}
