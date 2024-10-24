#Snakefile

import glob
import os

configfile: "config.yaml"
SAMPLE_DIR=config["sampledir"]

rule all:
        input: expand(["{outdir}/{sample}/{sample}_AMR_taxa_report.tsv"], outdir=config["outdir"], sample=config["sample"])

############################
## Filter out human reads

rule remove_host:
        input: os.path.join(SAMPLE_DIR, "{sample}.fastq.gz")
        output: "{outdir}/{sample}/{sample}.clean.fastq.gz"
        conda: "envs/hostile.yaml"
        threads: 4
        shell: """
                hostile clean --fastq1 {input} --out-dir {wildcards.outdir}/{wildcards.sample}
                """

############################
#  Assemble reads


rule metaMDBG:
        input: "{outdir}/{sample}/{sample}.clean.fastq.gz"
        output: "{outdir}/{sample}/metaMDBG/contigs.fasta.gz"
        conda: "envs/metaMDBG.yaml"
        threads: 4
        shell: """
                metaMDBG asm --out-dir {wildcards.outdir}/{wildcards.sample}/metaMDBG/ --in-ont {input} --threads {threads}
                """

rule unzip_fasta:
        input: "{outdir}/{sample}/metaMDBG/contigs.fasta.gz"
        output: "{outdir}/{sample}/metaMDBG/contigs.fasta"
        shell: """
                gzip -dk {input}
                sed -i '/^>/ s/ .*//' {output}
                """

#############################
# Gene call

rule Prodigal:
        input: "{outdir}/{sample}/metaMDBG/contigs.fasta"
        output:
                GFF="{outdir}/{sample}/{sample}.gff",
                ORF="{outdir}/{sample}/{sample}.faa"
        conda: "envs/prodigal.yaml"
        shell: """
                prodigal -i {input} -f gff -o {output.GFF} -a {output.ORF} -p meta
                sed -i '/^>/ s/contig.*ID=//;s/;.*//g;s/*//g' {output}
                """

#############################
# Annotations

rule rgi:
        input: "{outdir}/{sample}/{sample}.faa"
        output: "{outdir}/{sample}/rgi/{sample}.txt"
        conda: "envs/rgi.yaml"
        shell: """
                rgi main -i {input} -t protein -o {wildcards.sample} --clean --local
                mv {wildcards.sample}.txt {output}
                """

#######################
# Read mapping and summarization

rule creat_sam:
        input:
                fasta="{outdir}/{sample}/metaMDBG/contigs.fasta",
                reads="{outdir}/{sample}/{sample}.clean.fastq.gz"
        output: "{outdir}/{sample}/read_map/{sample}.sam"
        conda: "envs/bwa_sam.yaml"
        shell: """
                bwa index {input.fasta}
                bwa mem {input.fasta} {input.reads} > {output}
                """

rule sorted_bam:
        input: "{outdir}/{sample}/read_map/{sample}.sam"
        output: "{outdir}/{sample}/read_map/{sample}.sorted.bam"
        conda: "envs/bwa_sam.yaml"
        shell: """
                samtools sort {input} -o {output}
                """

rule summarize_count:
        input:
                BAM="{outdir}/{sample}/read_map/{sample}.sorted.bam",
                GFF="{outdir}/{sample}/{sample}.gff"
        output: "{outdir}/{sample}/read_map/{sample}_counts.tsv"
        conda: "envs/Subread.yaml"
        shell: """
                featureCounts -L -O -t CDS -g ID -o {output} -s 0 -a {input.GFF} {input.BAM}
                """

#########################
# TAXA

rule kraken:
        input: "{outdir}/{sample}/metaMDBG/contigs.fasta"
        output:
                OUTPUT= "{outdir}/{sample}/kraken/{sample}_contig_taxa.tsv",
                REPORT= "{outdir}/{sample}/kraken/{sample}_kraken_taxa.tsv"
        conda: "envs/kraken.yaml"
        threads: 4
        shell: """
                kraken2 --db Kraken_db --threads {threads} --output {output.OUTPUT} --use-names --report {output.REPORT} {input}
                """
#########################
# REPORT

rule R_AMR_report:
        input:
                RGI="{outdir}/{sample}/rgi/{sample}.txt",
                KRAKEN="{outdir}/{sample}/kraken/{sample}_contig_taxa.tsv",
                COUNT="{outdir}/{sample}/read_map/{sample}_counts.tsv"
        output:
                REPORT="{outdir}/{sample}/{sample}_AMR_taxa_report.tsv"
        conda: "envs/R.yaml"
        script:
                "scripts/AMR.R"
