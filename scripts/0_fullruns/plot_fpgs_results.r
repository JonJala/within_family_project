#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: create plots of fpgs results
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "tidyr", "dplyr", "magrittr", "tidyverse", "ggplot2",
                        "readxl", "stringr")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# create plots
# ---------------------------------------------------------------------

data <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_results.xlsx")

values <- data %>%
        select(ends_with(c("phenotype","_direct","_pop","_paternal","_maternal"))) %>%
        gather(measure, value, direct_direct:population_maternal)

se <- data %>%
        select(ends_with(c("phenotype", "direct_se", "pop_se", "paternal_se", "maternal_se"))) %>%
        gather(measure, se, direct_direct_se:population_maternal_se) %>%
        mutate(measure = substr(measure, 1, nchar(measure)-3))

df <- merge(values, se) %>%
        mutate(dir_pop = str_extract(measure, "[^_]+"),
        pheno_name = case_when(phenotype %in% c("aafb", "bmi", "bpd", "bps", "cpd", "dpw", "ea", "hdl", "swb") ~ toupper(phenotype),
                        !(phenotype %in% c("aafb", "bmi", "bpd", "bps", "cpd", "dpw", "ea", "hdl", "swb", "nonhdl")) ~ str_to_title(phenotype),
                        phenotype == "nonhdl" ~ "Non-HDL"),
        validation = case_when(phenotype %in% c("agemenarche", "bmi", "cognition", "depsymp", "dpw", "ea", "extraversion", "health", "neuroticism", "swb") ~ "mcs",
                        !(phenotype %in% c("agemenarche", "bmi", "cognition", "depsymp", "dpw", "ea", "extraversion", "health", "neuroticism", "swb")) ~ "ukb"))

fpgs_plot <- function(data, dirpop, valid, ncols = 5) {
        lvls <- c(paste0(dirpop, "_direct"), paste0(dirpop, "_maternal"), paste0(dirpop, "_paternal"), paste0(dirpop, "_pop"))
        p <- ggplot(data %>% filter(validation == valid, dir_pop == dirpop),
                aes(x = factor(measure, levels = lvls), y = value, fill = factor(measure, levels = lvls))) +
        geom_bar(stat = "identity") +
        geom_hline(yintercept = 0) +
        geom_linerange(aes(ymin = value - 1.96*se, ymax = value + 1.96*se), colour="black", size = 0.5) +
        theme_classic() +
        scale_fill_discrete(labels = c("Direct", "Maternal", "Paternal", "Population")) +
        theme(legend.title = element_blank(), legend.position = "bottom", axis.text.x = element_blank(),
                axis.ticks.x = element_blank(), axis.text.y = element_text(size = 14),
                axis.title = element_blank(), strip.text.x = element_text(size = 14)) +
        facet_wrap(~pheno_name, ncol = ncols)
        print(p)
        ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_", dirpop, "_effects_", valid, ".png"), p)
}

fpgs_plot(df, "direct", "mcs")
fpgs_plot(df, "population", "mcs")

fpgs_plot(df, "direct", "ukb")
fpgs_plot(df, "population", "ukb")