#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: get plink files for howe et al info score analysis
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

set.seed(42)

## ---------------------------------------------------------------------
## create keep files
## ---------------------------------------------------------------------

## list of snps to keep

# read in chr 1 data
dat <- fread("/disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_mfi_chr1_v3.txt")

# filter to low info snps
low_info <- dat %>%
                filter(0.3 < V8 & V8 < 0.31) # filter info score between 0.3 and 0.31
low_info_snps <- sample(low_info$V2, 100, replace = FALSE) # randomly select 100 snps
fwrite(data.frame(low_info_snps), "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/low_info_snps.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)

# high info snps
high_info <- dat %>%
                filter(V8 > 0.99)
high_info_snps <- sample(high_info$V2, 100, replace = FALSE)
fwrite(data.frame(high_info_snps), "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/high_info_snps.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)

## ---------------------------------------------------------------------
## create sample file
## ---------------------------------------------------------------------

# read in sibs
sibs <- fread("/disk/genetics/ukb/alextisyoung/haplotypes/relatives/bedfiles/hap.kin0") # list of sibs in UKB
sibs %<>% filter(InfType == "FS") # full sibs only
sib1 <- data.frame(sibs$FID1, sibs$ID1, fix.empty.names =  FALSE)
sib2 <- data.frame(sibs$FID2, sibs$ID2, fix.empty.names =  FALSE)
all_sibs <- rbind(sib1, sib2)
fwrite(all_sibs, "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/all_sibs.txt", col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")
