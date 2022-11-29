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
# read in data
# ---------------------------------------------------------------------

data <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_results.xlsx")

# select cols of interest
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


# df <- data %>%
#         mutate(direct_avgNTC = (direct_paternal + direct_maternal)/2, population_avgNTC = (population_paternal + population_maternal)/2) %>%
#         select(ends_with(c("phenotype","_direct","_pop","_avgNTC"))) %>%
#         gather(measure, value, direct_direct:population_avgNTC) %>%
#         mutate(dir_pop = str_extract(measure, "[^_]+"),
#         pheno_name = case_when(phenotype %in% c("aafb", "bmi", "bpd", "bps", "cpd", "dpw", "ea", "hdl", "swb") ~ toupper(phenotype),
#                         !(phenotype %in% c("aafb", "bmi", "bpd", "bps", "cpd", "dpw", "ea", "hdl", "swb", "nonhdl")) ~ str_to_title(phenotype),
#                         phenotype == "nonhdl" ~ "Non-HDL")) %>%
#         arrange(phenotype)
# # df$pheno_name

# phenos <- c('aafb', 'agemenarche', 'asthma', 'bmi', 'bpd', 'bps', 'cognition', 'cpd', 'depsymp',
#                  'dpw', 'ea', 'extraversion', 'hayfever', 'hdl', 'health', 'income',
#                  'migraine', 'nchildren', 'nearsight', 'neuroticism', 'nonhdl', 'swb')
phenos <- c('aafb', 'agemenarche', 'asthma', 'bmi', 'bpd', 'bps', 'cognition', 'cpd')
phenos <- c('depsymp', 'dpw', 'ea', 'extraversion', 'hayfever', 'hdl', 'health', 'income')
phenos <- c('migraine', 'nchildren', 'nearsight', 'neuroticism', 'nonhdl', 'swb')

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



p <- ggplot(df %>% filter(dir_pop == "direct", phenotype %in% phenos), aes(x = factor(measure, levels = c("direct_direct", "direct_avgNTC", "direct_pop")), y = value, fill = factor(measure, levels = c("direct_direct", "direct_avgNTC", "direct_pop")))) +
    geom_bar(stat = "identity") +
    geom_hline(yintercept = 0) +
    # geom_linerange(aes(ymin = value - 1.96*se, ymax = value + 1.96*se), colour="black", size = 0.5) +
    theme_classic() +
    scale_fill_discrete(labels = c("Direct", "Average NTC", "Population")) +
    theme(legend.title = element_blank(), legend.position = "bottom", axis.text.x = element_blank(),
            axis.ticks.x = element_blank(), axis.text.y = element_text(size = 14),
            axis.title = element_blank(), strip.text.x = element_text(size = 14)) +
    facet_wrap(~pheno_name, ncol = 4)
print(p)
ggsave("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_direct_effects_1.png", p)
ggsave("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_direct_effects_2.png", p)
ggsave("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_direct_effects_3.png", p)
