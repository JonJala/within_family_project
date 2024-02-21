#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: qqplot for p-vals of cross-trait rg differences
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "dplyr", "tidyverse", "ggplot2", "readxl")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## make qqplot
## ---------------------------------------------------------------------

## read in genomicSEM results
results <- read_xlsx("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/cross_trait_results.xlsx")

# Theoretical quantile function
qlog10 <- function(p.values) {
  theoretical <- rank(p.values)/length(p.values)
  return(-log10(theoretical))
}

# QQplot
ggplot(results, aes(x = qlog10(p), y = -log10(p))) + 
  geom_point() +
  geom_abline(intercept = 0, slope = 1) +
  labs(x = "Expected -log10(p)", y = "Observed -log10(p)") +
  theme_minimal()
ggsave("/var/genetics/proj/within_family/within_family_project/processed/figures/rg_qqplot.jpg", width = 6, height = 6)
