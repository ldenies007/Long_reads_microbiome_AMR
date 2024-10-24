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
```
# For kraken all databases can be found at https://benlangmead.github.io/aws-indexes/k2
~
