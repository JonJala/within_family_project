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
# format data
# ---------------------------------------------------------------------

data <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_results.xlsx")

values <- data %>%
        select(ends_with(c("phenotype","_direct","_pop","_paternal","_maternal","_corr"))) %>%
        gather(measure, value, direct_direct:population_parental_pgi_corr)

se <- data %>%
        select(ends_with(c("phenotype", "direct_se", "pop_se", "paternal_se", "maternal_se", "_corr_se"))) %>%
        gather(measure, se, direct_direct_se:population_parental_pgi_corr_se) %>%
        mutate(measure = substr(measure, 1, nchar(measure)-3))

capitalized <- c("adhd", "bmi", "ea", "hdl")
mcs_phenos <- c('ea', 'cognition', 'bmi', 'depression', 'adhd', 'agemenarche', 'eczema', 'cannabis' ,'dpw', 'depsymp', 'eversmoker', 'extraversion', 'neuroticism', 'health', 'height', 'hhincome', 'swb')
df <- merge(values, se) %>%
        mutate(dir_pop = str_extract(measure, "[^_]+"),
        pheno_name = case_when(phenotype %in% capitalized ~ toupper(phenotype),
                        phenotype == "nonhdl" ~ "Non-HDL",
                        phenotype == "fev" ~ "FEV1",
                        phenotype == "agemenarche" ~ "Age-at-menarche",
                        phenotype == "bps" ~ "BPS",
                        phenotype == "bpd" ~ "BPD",
                        phenotype == "cognition" ~ "Cognitive performance",
                        phenotype == "depsymp" ~ "Depressive symptoms",
                        phenotype == "eversmoker" ~ "Ever-smoker",
                        phenotype == "dpw" ~ "Drinks-per-week",
                        phenotype == "hayfever" ~ "Allergic rhinitis",
                        phenotype == "health" ~ "Self-rated health",
                        phenotype == "hhincome" ~ "Household income",
                        phenotype == "swb" ~ "Subjective well-being",
                        phenotype == "nchildren" ~ "Number of children",
                        phenotype == "nearsight" ~ "Myopia",
                        phenotype == "aud" ~ "Alcohol use disorder",
                        phenotype == "cpd" ~ "Cigarettes per day",
                        phenotype == "aafb" ~ "Age at first birth",
                        phenotype == "morningperson" ~ "Morning person",
                        phenotype %in% c("asthma", "cannabis", "depression", "eczema", "extraversion", "height", "income", "migraine", "neuroticism") ~ str_to_title(phenotype)),
        validation = case_when(phenotype %in% mcs_phenos ~ "mcs",
                        !(phenotype %in% mcs_phenos) ~ "ukb"))

# ---------------------------------------------------------------------
# plot fpgs coefficients
# ---------------------------------------------------------------------

fpgs_plot <- function(data, dirpop, valid, ncols = 6) {
        lvls <- c(paste0(dirpop, "_direct"), paste0(dirpop, "_maternal"), paste0(dirpop, "_paternal"), paste0(dirpop, "_pop"))
        p <- ggplot(data %>% filter(validation == valid, dir_pop == dirpop, measure %in% lvls),
                aes(x = factor(measure, levels = lvls), y = value, fill = factor(measure, levels = lvls))) +
        geom_bar(stat = "identity") +
        geom_hline(yintercept = 0) +
        geom_linerange(aes(ymin = value - 1.96*se, ymax = value + 1.96*se), colour="black", linewidth = 0.5) +
        theme_classic() +
        scale_fill_discrete(labels = c("Direct", "Maternal", "Paternal", "Population")) +
        theme(legend.title = element_blank(), legend.position = "bottom", axis.text.x = element_blank(),
                axis.ticks.x = element_blank(), axis.text.y = element_text(size = 11),
                axis.title = element_blank(), strip.text.x = element_text(size = 9.5)) +
        facet_wrap(~pheno_name, ncol = ncols, labeller = labeller(phenoname = label_wrap_gen(10)))
        print(p)
        ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/figures/fpgs_plots/fpgs_", dirpop, "_effects_", valid, ".png"), p, width = 10, height = 10)
}

fpgs_plot(df, "direct", "mcs")
fpgs_plot(df, "population", "mcs")
fpgs_plot(df, "direct", "ukb")
fpgs_plot(df, "population", "ukb")

# ---------------------------------------------------------------------
# plot fpgs coefficients for ea and cognition
# ---------------------------------------------------------------------

fpgs_ea_cog <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_results_ea_cognition.xlsx")
fpgs_ea_cog %<>% fill(phenotype, validation_pheno) # fill down missing phenotype values from merged rows

values_ea_cog <- fpgs_ea_cog %>%
                select(ends_with(c("phenotype", "dataset", "pheno", "_direct","_pop","_paternal","_maternal","_corr"))) %>%
                gather(measure, value, direct_direct:population_parental_pgi_corr)
se_ea_cog <- fpgs_ea_cog %>%
        select(ends_with(c("phenotype", "dataset", "pheno",  "direct_se", "pop_se", "paternal_se", "maternal_se", "_corr_se"))) %>%
        gather(measure, se, direct_direct_se:population_parental_pgi_corr_se) %>%
        mutate(measure = substr(measure, 1, nchar(measure)-3))
df_ea_cog <- merge(values_ea_cog, se_ea_cog) %>%
        mutate(dir_pop = str_extract(measure, "[^_]+"),
                validation_pheno_name = case_when(dataset == "mcs" & validation_pheno == "cognition" ~ "MCS S7 Cognitive Assessment",
                                                  dataset == "mcs" & validation_pheno == "cogverb" ~ "MCS S6 Word Activity",
                                                  dataset == "mcs" & validation_pheno == "ea" ~ "Avg. Eng. & Math GCSE Score",
                                                  dataset == "ukb" & validation_pheno == "ea" ~ "EA4 Outcome",
                                                  dataset == "ukb" & validation_pheno == "cognition" ~ "UKB Fluid Intelligence"))

fpgs_plot_ea_cog <- function(data, dirpop, pheno, ylim, ncols = 3) {
        lvls <- c(paste0(dirpop, "_direct"), paste0(dirpop, "_maternal"), paste0(dirpop, "_paternal"), paste0(dirpop, "_pop"))
        p <- ggplot(data %>% filter(phenotype == pheno, dir_pop == dirpop, measure %in% lvls),
                aes(x = factor(measure, levels = lvls), y = value, fill = factor(measure, levels = lvls))) +
        geom_bar(stat = "identity") +
        geom_hline(yintercept = 0) +
        geom_linerange(aes(ymin = value - 1.96*se, ymax = value + 1.96*se), colour="black", linewidth = 0.5) +
        theme_classic() +
        ylim(ylim) +
        scale_fill_discrete(labels = c("Direct", "Maternal", "Paternal", "Population")) +
        theme(legend.title = element_blank(), legend.position = "bottom", axis.text.x = element_blank(),
                axis.ticks.x = element_blank(), axis.text.y = element_text(size = 9),
                axis.title = element_blank(), strip.text.x = element_text(size = 8)) +
        facet_wrap(~validation_pheno_name, ncol = ncols)
        print(p)
        ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/figures/fpgs_plots/fpgs_", dirpop, "_effects_", pheno, ".png"), p)
}

fpgs_plot_ea_cog(df_ea_cog, "direct", "ea", ylim = c(-0.08, 0.28))
fpgs_plot_ea_cog(df_ea_cog, "population", "ea", ylim = c(-0.08, 0.28))
fpgs_plot_ea_cog(df_ea_cog, "direct", "cognition", ylim = c(-0.05, 0.15))
fpgs_plot_ea_cog(df_ea_cog, "population", "cognition", ylim = c(-0.05, 0.15))

# ---------------------------------------------------------------------
# plot parental pgi corrs
# ---------------------------------------------------------------------

# append ukb cog and mcs parental corrs to data
pgi_corrs <- df %>% filter(measure == "population_parental_pgi_corr" | measure == "direct_parental_pgi_corr")
ea_cog_corrs_ukb <- df_ea_cog %>% 
                        filter((measure == "population_parental_pgi_corr" | measure == "direct_parental_pgi_corr") & validation_pheno == "ea4") %>%
                        mutate(validation = "ukb",
                                pheno_name = case_when(phenotype == "ea" ~ "EA",
                                                        phenotype == "cognition" ~ "Cognition")) %>%
                        select(phenotype, measure, value, se, dir_pop, pheno_name, validation)
corrs_df <- rbind(pgi_corrs, ea_cog_corrs_ukb)

plot_parental_corrs <- function(data, valid, ncols = 5) {
        lvls <- c("direct_parental_pgi_corr", "population_parental_pgi_corr")
        p <- ggplot(data %>% filter(validation == valid, measure %in% lvls),
                aes(x = factor(measure, levels = lvls), y = value, fill = factor(measure, levels = lvls))) +
        geom_bar(stat = "identity") +
        geom_hline(yintercept = 0) +
        geom_linerange(aes(ymin = value - 1.96*se, ymax = value + 1.96*se), colour="black", linewidth = 0.5) +
        theme_classic() +
        scale_fill_discrete(labels = c("Direct", "Population")) +
        theme(legend.title = element_blank(), legend.position = "bottom", axis.text.x = element_blank(),
                axis.ticks.x = element_blank(), axis.text.y = element_text(size = 11),
                axis.title = element_blank(), strip.text.x = element_text(size = 11)) +
        facet_wrap(~pheno_name, ncol = ncols)
        print(p)
        ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/figures/fpgs_plots/parental_corrs_", valid, ".png"), p, width = 10, height = 10)
}

plot_parental_corrs(corrs_df, "mcs")
plot_parental_corrs(corrs_df, "ukb")