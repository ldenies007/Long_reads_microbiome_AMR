#!/usr/bin/env R

library(tidyverse)

#############
# AMR
RGI <- read.delim(file=snakemake@input[["RGI"]])
RGI_select <- RGI %>% select(ORF_ID, Cut_Off, Best_Hit_Bitscore, Best_Identities, Best_Hit_ARO, ARO, SNPs_in_Best_Hit_ARO, Drug.Class, Resistance.Mechanism, AMR.Gene.Family, Antibiotic)
RGI_select <- RGI_select %>% mutate(contig = gsub(" #.*","",ORF_ID)) %>% mutate(ORF_ID = gsub(".* ID=","", ORF_ID)) %>% select(1,12,2:11)

############
# Taxa
KRAKEN <- read.delim(file=snakemake@input[["KRAKEN"]], header=FALSE)
KRAKEN <- KRAKEN %>% select(V2, V3)
colnames(KRAKEN) <- c("Contig","Taxa")

############
# Count
COUNT <- read.delim(file=snakemake@input[["COUNT"]], comment.char="#")
colnames(COUNT)[7] <- "read_count"

COUNT <- COUNT %>% mutate(ORF_ID = Geneid, Contig = Chr) %>% select(Contig, ORF_ID, Length, read_count)
COUNT <- COUNT %>% mutate(Norm_read_count = read_count/Length) %>% mutate(total_norm = sum(Norm_read_count)) %>% mutate(relab=Norm_read_count/total_norm*100)

############
# Report
REPORT <- left_join(RGI_select, COUNT)
REPORT <- left_join(REPORT, KRAKEN)

write.table(REPORT, file=snakemake@output[["REPORT"]], sep="\t", row.names=FALSE, quote=FALSE)
