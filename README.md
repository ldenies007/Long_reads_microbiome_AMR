# Long_reads_microbiome_AMR
Pipeline to analyze ONT long read data (Taxonomy, AMR)

# Installation
## Requirements
The main requirements are:
- gcc/g++
- git and git lfs
- conda (version >4.9.2)

Most other dependencies will be installed automatically by snakemake using the conda YAML files in envs/.
However, some tools need to be installed and/or configured manually.

## Install miniconda3 (if not already installed)
```
wget https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh
chmod u+x Miniconda3-py37_4.9.2-Linux-x86_64.sh
./Miniconda3-py37_4.9.2-Linux-x86_64.sh # follow the instructions
```
## Clone repository
```
# activate git lfs
git lfs install
# clone branch incl. sub-modules
git clone -b master --recursive https://github.com/ldenies007/Long_reads_microbiome_AMR.git
```
## Pipeline environment (snakemake)
```
# create the conda environment - primarily snakemake
conda env create -f=envs/Snakemake.yaml
```
You can activate and deactivate the environment using *conda activate Snakemake* and *conda deactivate*

## Download databases
Before running the pipeline for the first time you need to download the kraken2 and RGI (CARD) databases.

# For kraken all databases can be found at 
https://benlangmead.github.io/aws-indexes/k2
```
# Navigate the pipeline and create sub-directory for the kraken database
cd Long_reads_microbiome_AMR
mkdir kraken_db
# Download the standard-16 database
wget https://genome-idx.s3.amazonaws.com/kraken/k2_standard_16gb_20240904.tar.gz
# Unzip and move to the sub-directory *kraken_db*
tar -xf k2_standard_16gb_20240904.tar.gz -C kraken_db
# remove *tar.gz to save space
rm -rf k2_standard_16gb_20240904.tar.gz
```
# Download RGI database for RGI 
(https://github.com/arpcard/rgi)
```
conda env create -f=envs/RGI.yaml
conda activate RGI
# follow the instructions from: https://github.com/arpcard/rgi/blob/master/docs/rgi_load.rst
wget https://card.mcmaster.ca/latest/data
tar -xvf data ./card.json
rgi load --card_json /path/to/card.json --local
```

# Run pipeline
## Input files
Each sample should have one input file:
- *fastq.gz: FASTA file containing long read sequences (ONT)
## Configuration
To run the pipeline you need to adjust some parameters in the [config.yaml]
- [sample]:  This is a list of sample names, e.g. sample: ["SAMPLE_A","SAMPLE_B"]
- [sampledir]: Path to directory containing the sample data
- [outdir]: The output directory where the results will be saved

*optional*
- [threads]: The number of threads can be scaled up or down - number of threads used for the assembly step

## Execution
Basic command to run the pipeline using [<cores>] CPUs:
```
# activate the env
conda activate Snakemake
#  run the pipeline
# set <cores> to the number of cores to use, e.g. **4** - to a limited extend when running multiple samples at the same time scaling up the cores will increase parallelization of the pipeline
snakemake -s Snakefile --use-conda --reason --cores <cores> -p
```
NOTE: Add parameter -n (or --dry-run) to the command to see which steps will be executed without running them.

NOTE: Add --configfile <configfile.yaml> to use a different config file than config.yaml.


