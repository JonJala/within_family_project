#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: info score analysis for howe et al. paper
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "bigsnpr", "plinkFile", "genio")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

set.seed(42)

## ---------------------------------------------------------------------
## create sample and snp files to filter bgen in plink
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
high_info <- data %>%
                    filter(V8 > 0.99)
high_info_snps <- sample(high_info$V2, 100, replace = FALSE)
fwrite(data.frame(high_info_snps), "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/high_info_snps.txt", col.names = FALSE, row.names = FALSE, quote = FALSE)


## list of sibs

# read in sibs
sibs <- fread("/disk/genetics/ukb/alextisyoung/haplotypes/relatives/bedfiles/hap.kin0") # list of sibs in UKB
sibs %<>% filter(InfType == "FS") # full sibs only
sib1 <- data.frame(sibs$FID1, sibs$ID1, fix.empty.names =  FALSE)
sib2 <- data.frame(sibs$FID2, sibs$ID2, fix.empty.names =  FALSE)
all_sibs <- rbind(sib1, sib2)
fwrite(all_sibs, "/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_analysis/all_sibs.txt", col.names = FALSE, row.names = FALSE, quote = FALSE, sep = "\t")

## ---------------------------------------------------------------------
## analysis using plink generated files
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
