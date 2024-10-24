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

## install miniconda3 (if not already installed)
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
git clone -b master --recursive
```
