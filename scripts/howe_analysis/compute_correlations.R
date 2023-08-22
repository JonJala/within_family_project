#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: compute gcs between sibs for howe et al info score analysis
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "plinkFile", "genio")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## compute correlations using plink filtered files
## ---------------------------------------------------------------------

compute_corrs <- function(bed_path, fam_path, sibs) {
    
    ## read in bed and fam files
    bed <- readBED(bed_path)
    fam <- read_fam(fam_path)

    ## process sibling data
    bed_dat <- data.table(ID = as.numeric(fam$id), bed)
    sib1_dat <- sibs %>%
                    select(ID1) %>%
                    rename(ID = ID1) %>%
                    left_join(bed_dat)
    sib2_dat <- sibs %>%
                    select(ID2) %>%
                    rename(ID = ID2) %>%
                    left_join(bed_dat)

    ## compute corrs
    cors <- c()
    for (i in 1:100) {
        j <- i + 1
        cor <- cor(sib1_dat[, ..j], sib2_dat[, ..j], use = "pairwise.complete.obs")
        cors <- append(cors, cor[1])
    }

    return(unlist(cors))

}

## compute correlations for low info snps
low_info_bed <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/all_sibs_low_info.bed" 
low_info_fam <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/all_sibs_low_info.fam"
low_info_corr <- compute_corrs(low_info_bed, low_info_fam, sibs)
hist(low_info_corr)
mean(low_info_corr)

## compute correlations for high info snps
high_info_bed <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/all_sibs_high_info.bed" 
high_info_fam <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/all_sibs_high_info.fam"
high_info_corr <- compute_corrs(high_info_bed, high_info_fam, sibs)
hist(high_info_corr)
mean(high_info_corr)
