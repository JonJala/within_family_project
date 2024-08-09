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
dat <- fread("/disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_mfi_chr1_v3.txt") # 7.4 million SNPs
dat %<>% filter(V6 > 0.01) # filter MAF > 0.01 as per howe et al.; 772k SNPs left

# filter to snps with info score 0.3-0.99 at 0.01 intervals
for (i in seq(0.3, 0.99, 0.01)) {
    j <- i + 0.01
    info <- dat %>%
            filter(i <= V8 & V8 < j) # filter info score
    if (nrow(info) >= 1000) {
        print(paste0("Randomly selecting 1k SNPs with INFO between ", i, " and ", j, "."))
        snps <- sample(info$V2, 1000, replace = FALSE) # randomly select 1000 snps
    } else {
        print(paste0("Less than 1k SNPs available, selecting all ", nrow(info), " SNPs with INFO between ", i, " and ", j, "."))
        snps <- info$V2 # select all SNPs available
    }
    k <- str_replace(as.character(i), "\\.", "_")
    fwrite(data.frame(snps), paste0("/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/keep/snps_", k, ".txt"), col.names = FALSE, row.names = FALSE, quote = FALSE)
}

## ---------------------------------------------------------------------
## create sample file
## ---------------------------------------------------------------------

# read in sibs
sibs <- fread("/disk/genetics/ukb/alextisyoung/haplotypes/relatives/bedfiles/hap.kin0") # list of sibs in UKB
sibs %<>% filter(InfType == "FS") # full sibs only
sib1 <- data.frame(sibs$FID1, sibs$ID1, fix.empty.names =  FALSE)
sib2 <- data.frame(sibs$FID2, sibs$ID2, fix.empty.names =  FALSE)
all_sibs <- rbind(sib1, sib2)
fwrite(all_sibs, "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/all_sibs.txt", col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")
