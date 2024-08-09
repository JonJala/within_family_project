#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: create figures for supplementary note
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "tidyr", "dplyr", "magrittr", "tidyverse", "ggplot2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# SEF figure
# ---------------------------------------------------------------------

data <- fread("/disk/genetics/proj/within_family/within_family_project/processed/qc/fhs/bmi/CLEANED.out.gz")

data %<>% 
    mutate(sef_x = sqrt(f*(1-f)))

p <- data %>%
        ggplot(aes(x = sef_x, y = se_direct)) +
        geom_point() +
        xlab(bquote(sqrt("f(1-f)"))) +
        ylab("Standard Error of Direct Genetic Effects") +
        theme_classic() +
        theme(panel.grid.major = element_line(color = "grey",
                                        linewidth = 0.5,
                                        linetype = 2))
# ggsave("/var/genetics/proj/within_family/within_family_project/doc/exampleplots/fhs_bmi_sef.pdf", p)
ggsave("/var/genetics/proj/within_family/within_family_project/doc/exampleplots/fhs_bmi_sef.jpg", p) # pdf file is very large

# ---------------------------------------------------------------------
# Neff vs AF
# ---------------------------------------------------------------------

p <- data %>%
        ggplot(aes(x = f, y = n_direct)) +
        geom_point() +
        xlab("Allele Frequency") +
        ylab("Effective N for Direct Genetic Effects") +
        theme_classic() +
        theme(panel.grid.major = element_line(color = "grey",
                                        linewidth = 0.5,
                                        linetype = 2))
ggsave("/var/genetics/proj/within_family/within_family_project/doc/exampleplots/fhs_bmi_neff_af.jpg", p)
