#!/mnt/apps/users/whuang/conda/bin/nextflow

/*
 *  Pipeline developed for the QC of ancient DNA Illumina PE raw reads.
 *  Author: Wu Huang <hazelhuang1993@icloud.com>
 *  Date last modified: 29/05/2025
 */
                                                            // ========================================================
                                                            // Setting the help messages up
                                                            // ========================================================
def helpMessage() {
  log.info """
Pipeline developed for a thorough ancient DNA Illumina PE raw short read quality control.
CropDiversity HPC limits users to 256 CPUs and 256Gb mem max for each queue. Use multiple queues if you'd like to speed up the process.

MainSteps:
Falco -> FastP -> FalcoAfterFastP
               -> KmerAnalysis
			   -> fqStat(Statistics_Summarize)

Usage:
1. Create the conda3 environment using 'conda env create --name ReadsQC --file ReadsQC.yml'
2. Update project directory in ReadsQC.sh
3. Specify required arguments for each step in the nextflow.config file
4. Submit pipeline using 'sbatch --export=BATCH_ID=06_2025.07.09_EdGen_192_samples ReadsQC.sh'

Required arguments:
  --InDir                                     Path to directory with fastq files (ideally, gzip compressed files)
  --OutDir                                    Path to output directory
  --Li                                        Path to the sample.list file
  --Batch_ID                                  Batch ID

  """
}


if (params.help) {
    helpMessage()
    exit 0
}


if(!params.InDir) {
  log.info"""
ERROR: Path to raw reads directory must be provided! --InDir /path/to/fastqs/
  """
  helpMessage()
  exit 0
}


if(!params.Li) {
  log.info"""
ERROR: Please provide a list of sample IDs --Li /path/to/sample.list
Example file please see example/sample.list
  """
  helpMessage()
  exit 0
}


                                                            // ========================================================
                                                            // Defining Processes
                                                            // ========================================================

/*
 * Step 1: falcoQC of raw reads, export falcoQC report
 */

include {falcoQC} from './modules/falcoQC.nf'


/*
 * Step 2: Trimming and merge the raw reads, export trimmed and merged reads
 */

include {fastp} from './modules/fastp.nf'


/*
 * Step 3: falcoQC of trimmed reads, export falcoQC report
 */

include {falcoQCafterFastp} from './modules/falcoQCafterFastp.nf'


/*
 * Step 4: Kmer analysis of the trimmed and merged reads
 */

include {kmerAnalysis} from './modules/kmerAnalysis.nf'


/*
 * Step 5: collect statistics of each step
 */

include {fqStat} from './modules/fqStat.nf'



                                                            // ========================================================
                                                            // Setting up the channels
                                                            // ========================================================

sample_ID_ch = Channel.fromPath(params.Li)
                      .splitCsv(header:false)
					  .map { row -> row[0]}


                                                            // ========================================================
                                                            // Main workflow
                                                            // ========================================================
workflow {

falcoQC(sample_ID_ch)
fastp_out_ch = fastp(sample_ID_ch)
falcoQCafterFastp(fastp_out_ch)
kmerAnalysis(fastp_out_ch)
fqStat_out_ch = fqStat(fastp_out_ch)

}
