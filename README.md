# Nextflow workflow: `FSP_RawReads_Processing`

[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.10.3-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![DOI](https://zenodo.org/badge/DOI/17608339.svg)](https://doi.org/10.5281/zenodo.17608339)

![Bioinformatics team](https://github.com/user-attachments/assets/b8d1ee40-73c1-477d-b7cf-30992de1c884)


## Overview

This is a nextflow workflow for QC, clean, merge Illumina reads and create kmer profiles. 

This workflow was developed for the [Fungarium Sequencing Project (FSP)](https://www.kew.org/science/our-science/projects/sequencing-kews-fungarium) at Royal Botanic Gardens, Kew. It may be useful to other projects that deal with difficult samples with degraded DNA for genome assembly purposes.

The workflow was designed to process hundreds of samples in parallel. 

- [Nextflow workflow: FSP_RawReads_Processing](#nextflow-workflow-fsp_rawreads_processing)
  - [Overview](#overview)
    - [Input & Output](#input--output)
  - [Usage](#usage)
    - [Clone the repo](#clone-the-repo)
    - [Set up dependancies](#set-up-dependancies)
    - [Prepare the required inputs](#prepare-the-required-inputs)
      - [1. Your input data directory structure](#1-your-input-data-directory-structure)
      - [2. Prepare the file sample.list](#2-prepare-the-file-sample-list)
      - [3. Set up nextflow.config](#3-set-up-nextflow-config)
    - [Run the workflow](#run-the-workflow)
      - [1. Run with command line](#1-run-with-command-line)
      - [2. Run with submission script](#2-run-submission-script)
      - [3. Monitor the progress](#3-monitor-the-progress)
  - [Authors](#authors)
  - [References](#references)


### Input & Output
Inputs: 

Raw sequence data by Illumina short read sequencers

Outputs: 
- clean, deduplicated reads with < 30bp removed.
- QC reports for each sample of both raw and clean reads
- QC statistics of the whole batch, including data size, read number, read length, GC content, duplication leveletc.
- Sequencing complexity accumulating graphs for each sample
- K-mer distribution graphs for each sample
K-mer statistics of the whole batch, including uniq kmer number, total kmer number, estimated genome size, peak coverage etc.

## Usage

### Clone the repo

```
cd /your_target_folder/
git clone https://github.com/Hazelhuangup/FSP_RawReads_Processing.git
```

### Set up dependancies

- Add /your_target_folder/FSP_RawReads_Processing/bin/ to your $PATH
```
echo 'export PATH=/your_target_folder/FSP_RawReads_Processing/bin' >> ~/.bashrc
```
- Install [Nextflow](#https://www.nextflow.io/docs/latest/install.html)

- Install [kmer-cnt](#https://github.com/lh3/kmer-cnt?tab=readme-ov-file)
  -  The robin_hood.h file in this package needs some editing. Replace robin_hood.h in your installed package by the one provided in the 00_nf_QC/bin folder.

### Prepare the required inputs

#### 1. Your input data directory structure

The directory that contains your input samples (e.g. `Batch_1`) must be structured in the following way:
```
Batch_1/
├── Sample_001
│   ├── Sample_001_R1.fastq.gz
│   └── Sample_001_R2.fastq.gz
├── Sample_002
│   ├── Sample_002_R1.fastq.gz
│   └── Sample_002_R2.fastq.gz
├── Sample_003
│   ├── Sample_003_R1.fastq.gz
│   └── Sample_003_R2.fastq.gz
└── sample.list

```
#### 2. Prepare the file sample.list
The file sample.list is a list of samples.
```
Sample_001
Sample_002
Sample_003
```
If all the files you received are in one folder, you can use the following script structure the folder, and create the sample.list file. Adapt batch ID in this script. Be aware of the folder names can be adjusted at line 12 in the script.
```
bin/paired_dir.sh
```

#### 3. Set up nextflow.config
- Change the where you'd like to cache the conda environment. If you leave it blank, by default it's in ./work/conda.
```
vim nextflow.config
cacheDir = './your-desired-path/'
```

### Running the workflow
#### 1. Run with command line
```
nextflow run ReadQC.nf -profile conda -resume\
    --InDir /your/input/directory/Batch_1\
    --OutDir /your/output/directory/Batch_1\
    --Li /your/absolute/directory/to/sample.list\
    --Batch_ID Batch_1
```
#### 2. Run with submission script
This Repo contains an example ReadQC.sh for running the pipeline in slurm managed HPC. Feel free to copy and replace the directories in ReadsQC.sh by yours. Make sure to set up your sbatch script according to your system settings. 
Then submit the script by 
```
sbatch --export=BATCH_ID=Batch_1 ReadQC.sh
```

#### 3. Monitor the progress:

```
# general check if your recent submissions are successful
nextflow log
# monitor the current run
cd /your_current_job_running_folder/
less QC_MAIN.log

```
## Authors

- Wu Huang
  - Royal Botanic Gardens, Kew
  - [ORCID profile](https://orcid.org/0000-0002-5015-7167)

The other members of the FSP bioinformatics team, [Lia Obinu](https://github.com/LiaOb21) and [Niall Garvey](https://github.com/NiallG1), and [George Mears](https://github.com/George-Mears) also contributed to the development and testing of this part of the workflow.

## Citation
Please cite the URL or DOI (10.5281/zenodo.17608339) if you use this workflow in a paper.

## References
1. P. Di Tommaso, et al. Nextflow enables reproducible computational workflows. Nature Biotechnology 35, 316–319 (2017) doi:10.1038/nbt.3820
2. Shifu Chen, et al, fastp: an ultra-fast all-in-one FASTQ preprocessor, Bioinformatics 34(17) 884–890 (2018), https://doi.org/10.1093/bioinformatics/bty560
3. de Sena Brandine G and Smith AD. Falco: high-speed FastQC emulation for quality control of sequencing data. F1000Research 8, 1874 (2021), https://doi.org/10.12688/f1000research.21142.2)
