#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: plot correlations from ldsc against those from snipar
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "tidyr", "dplyr", "magrittr", "tidyverse", "ggplot2",
                        "readxl", "stringr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## create plot
## ---------------------------------------------------------------------

# read in data
meta <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/meta_results.xlsx")

# get colour palette
n <- length(unique(meta$phenotype))
palette1 <- c("#E93993", "#CCEBDE", "#B2BFDC", "#C46627", "#10258A", "#E73B3C", "#DDDDDD",
                        "#FF8F1F", "#FCD3E6", "#B9E07A", "#A3F6FF", "#FFFF69", "#47AA42", "#A0DBD0",
                        "#5791C2", "#E9B82D", "#FC9284", "#7850A4", "#CEB8D7", "#FDC998", "#ADADAD",
                        "#00441B", "#028189", "#67001F", "#525252", "#FE69FC", "#A0D99B", "#4B1DB7")
palette2 <- sample(palette1, n-length(palette1), replace = F)
palette <- c(palette1, palette2)

# plot
ggplot(meta, aes(x = dir_pop_rg_ldsc, y = dir_pop_rg, colour = phenotype, shape = phenotype)) +
  geom_point() +
  geom_errorbar(aes(ymin = dir_pop_rg - dir_pop_rg_se, ymax = dir_pop_rg + dir_pop_rg_se), colour = "grey", alpha = 0.6) +
  geom_errorbar(aes(xmin = dir_pop_rg_ldsc - dir_pop_rg_se_ldsc, xmax = dir_pop_rg_ldsc + dir_pop_rg_se_ldsc), colour = "grey", alpha = 0.6) +
  geom_hline(yintercept=1, linetype="dotted") +
  geom_vline(xintercept=1, linetype="dotted") +
  xlim(0, 1.5) +
  ylim(0, 1.5) +
  scale_colour_manual(values = palette) +
  scale_shape_manual(values = c(seq(1, 25), seq(1,n-25))) +
  geom_abline(intercept = 0, slope = 1, color = "grey") +
  labs(x = "LDSC rg", y = "SNIPar rg") +
  theme_classic() +
  theme(legend.position = "bottom")
ggsave("/var/genetics/proj/within_family/within_family_project/processed/figures/ldsc_snipar_corrs.png", width = 10, height = 10, units = "in")
