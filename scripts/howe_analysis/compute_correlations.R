#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: compute gcs between sibs for howe et al info score analysis
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## compute correlations using plink filtered files
## ---------------------------------------------------------------------

compute_corrs <- function(raw_path, sibs) {
    
    ## read in .raw file
    raw <- fread(raw_path) %>%
                select(-FID, -PAT, -MAT, -SEX, -PHENOTYPE)

    ## merge with sibling data
    sib1_dat <- sibs %>%
                    select(ID1) %>%
                    rename(IID = ID1) %>%
                    left_join(raw)
    sib2_dat <- sibs %>%
                    select(ID2) %>%
                    rename(IID = ID2) %>%
                    left_join(raw)

    ## compute corrs
    cors <- c()
    for (i in 1:100) {
        j <- i + 1
        cor <- cor(sib1_dat[, ..j], sib2_dat[, ..j], use = "pairwise.complete.obs")
        cors <- append(cors, cor[1])
    }

    return(unlist(cors))

}

## read in sibs file
sibs <- fread("/disk/genetics/ukb/alextisyoung/haplotypes/relatives/bedfiles/hap.kin0") # list of sibs in UKB
sibs %<>% filter(InfType == "FS") # full sibs only

## compute correlations for low info snps
low_info_raw <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/all_sibs_low_info.raw" 
low_info_corr <- compute_corrs(low_info_raw, sibs)
hist(low_info_corr)
mean(low_info_corr, na.rm = T)
sum(is.na(low_info_corr))

## compute correlations for high info snps
high_info_raw <- "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/all_sibs_high_info.raw" 
high_info_corr <- compute_corrs(high_info_raw, sibs)
hist(high_info_corr)
mean(high_info_corr, na.rm = T)
sum(is.na(high_info_corr))