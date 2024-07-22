#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run QC checks on howe height sumstats
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "magrittr", "tidyverse", "vcfR")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## run QC
## ---------------------------------------------------------------------

vcf <- read.vcfR("/disk/genetics3/proj_dirs/within_family/within_family_project/scratch/ieu-b-4813.vcf.gz")

gt <- vcf@gt
df <- data.frame(gt[,2])
colnames(df) <- "data"

# Step 1: Extract the strings
strings <- df$data

# Step 2: Split each string by the colon separator
split_strings <- strsplit(strings, ":")

# Step 3: Combine the split components into a new DataFrame
new_df <- do.call(rbind, split_strings)

# Optionally, set column names if known
colnames(new_df) <- c("ES", "SE", "LP", "SS", "ID")

# Convert to data frame
new_df <- as.data.frame(new_df)

new_df$ES <- as.numeric(new_df$ES)
new_df$SE <- as.numeric(new_df$SE)
new_df$LP <- as.numeric(new_df$LP)
new_df$SS <- as.numeric(new_df$SS)

median(new_df$SS)

maf <- maf(vcf)


Mode <- function(x) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
Mode(new_df$SS)
