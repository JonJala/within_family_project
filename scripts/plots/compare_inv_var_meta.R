#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: compare results of inverse variance weighted 
#              meta-analysis to regular meta-analysis for EA
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "tidyr", "dplyr", "magrittr", "tidyverse", "ggplot2",
                        "readxl", "stringr", "RColorBrewer")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# plot figure
# ---------------------------------------------------------------------

# read in data
inv_meta = fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.inv.var.direct.sumstats.gz")
meta = fread("/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.sumstats.gz")

# subset to needed cols
meta %<>% select(cptid, direct_Beta, direct_SE)

# merge
merged = merge(meta, inv_meta, by = "cptid")

# plot
p = merged %>%
        ggplot() +
        geom_point(aes(x = direct_Beta, y = inv_var_direct), alpha=0.6) +
        geom_abline(intercept=0, slope=1, linetype="solid", color="gray") +
        geom_hline(yintercept=0, linetype="dotted") +
        geom_vline(xintercept=0, linetype="dotted") +
        labs(y = "Inverse Variance Weighted", x = "Regular Meta-Analysis")
ggsave("/var/genetics/proj/within_family/within_family_project/processed/figures/inv_var_meta_comparison.jpg", p)
