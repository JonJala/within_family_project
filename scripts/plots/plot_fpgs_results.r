#!/usr/bin/env Rscript

# ---------------------------------------------------------------------
# description: create plots of fpgs results
# ---------------------------------------------------------------------

list.of.packages <- c("data.table", "tidyr", "dplyr", "magrittr", "tidyverse", "ggplot2",
                        "readxl", "stringr", "RColorBrewer")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

# ---------------------------------------------------------------------
# format data
# ---------------------------------------------------------------------

data <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/fpgs_results.xlsx")

# filter on direct neff
meta <- read_excel("/var/genetics/proj/within_family/within_family_project/processed/package_output/meta_results.xlsx")
filtered_phenos <- meta %>%
                        filter(n_eff_median_direct > 5000) %>%
                        arrange(desc(n_eff_median_direct)) %>%
                        select(phenotype)

values <- data %>%
        filter(phenotype %in% filtered_phenos$phenotype) %>%
        select(ends_with(c("phenotype","_direct","_pop","_avg_ntc","_corr"))) %>%
        gather(measure, value, direct_direct:population_parental_pgi_corr)

se <- data %>%
        select(ends_with(c("phenotype", "direct_se", "pop_se", "avg_ntc_se", "_corr_se"))) %>%
        gather(measure, se, direct_direct_se:population_parental_pgi_corr_se) %>%
        mutate(measure = substr(measure, 1, nchar(measure)-3))

capitalized <- c("adhd", "bmi", "ea")
mcs_phenos <- c('ea', 'cognition', 'bmi', 'depression', 'adhd', 'agemenarche', 'eczema', 'cannabis' ,'dpw', 'depsymp', 'eversmoker', 'extraversion', 'neuroticism', 'health', 'height', 'hhincome', 'swb')
df <- merge(values, se) %>%
        mutate(dir_pop = str_extract(measure, "[^_]+"),
        pheno_name = case_when(phenotype %in% capitalized ~ toupper(phenotype),
                        phenotype == "nonhdl" ~ "Non-HDL cholesterol",
                        phenotype == "hdl" ~ "HDL cholesterol",
                        phenotype == "fev" ~ "FEV1",
                        phenotype == "agemenarche" ~ "Age-at-menarche",
                        phenotype == "bps" ~ "Blood pressure (systolic)",
                        phenotype == "bpd" ~ "Blood pressure (diastolic)",
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
                        phenotype == "aafb" ~ "Age at first birth (women)",
                        phenotype == "morningperson" ~ "Morning person",
                        phenotype == "income" ~ "Individual income",
                        phenotype %in% c("asthma", "cannabis", "depression", "eczema", "extraversion", "height", "migraine", "neuroticism") ~ str_to_title(phenotype)),
        validation = case_when(phenotype %in% mcs_phenos ~ "mcs",
                        !(phenotype %in% mcs_phenos) ~ "ukb"))
pheno_order <- df %>% arrange(factor(phenotype, levels = filtered_phenos$phenotype)) %>% select(pheno_name) %>% unique()

# colour palette
set.seed(42)
n <- length(unique(data$phenotype))
palette1 <- c("#E93993", "#CCEBDE", "#B2BFDC", "#C46627", "#10258A", "#E73B3C", "#DDDDDD",
                "#FF8F1F", "#FCD3E6", "#B9E07A", "#A3F6FF", "#47AA42", "#A0DBD0",
                "#5791C2", "#E9B82D", "#FC9284", "#7850A4", "#CEB8D7", "#FDC998", "#ADADAD",
                "#00441B", "#028189", "#67001F", "#525252", "#FE69FC", "#A0D99B", "#4B1DB7")
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
palette2 <- sample(col_vector, ifelse(n > 27, n-length(palette1), n), replace = F)
palette <- c(palette1, palette2)

# ---------------------------------------------------------------------
# plot fpgs coefficients
# ---------------------------------------------------------------------

fpgs_plot <- function(data, dirpop, ncols = 6) {
        lvls <- c(paste0(dirpop, "_direct"), paste0(dirpop, "_avg_ntc"), paste0(dirpop, "_pop"))
        data %<>% 
                filter(dir_pop == dirpop, measure %in% lvls) %>%
                mutate(measure = case_when(measure == paste0(dirpop, "_direct") ~ "Direct",
                                        measure == paste0(dirpop, "_avg_ntc") ~ "Average NTC",
                                        measure == paste0(dirpop, "_pop") ~ "Population"))
        p <- ggplot(data, aes(x = factor(pheno_name, level = rev(pheno_order$pheno_name)), y = value, colour = pheno_name, group = value), show.legend = F) +
                geom_point(aes(shape = factor(measure, levels = c("Population", "Direct", "Average NTC"))), position = position_dodge(width = 0.5), size=2) +
                geom_hline(yintercept = 0) +
                geom_errorbar(aes(x = pheno_name, ymin = value - 1.96*se, ymax = value + 1.96*se), width = 0.25, position = position_dodge(width = 0.5)) +
                theme_bw()+
                scale_colour_manual(values = palette, guide = "none") +
                scale_shape_manual(values = factor(data$measure, levels = c("Population", "Direct", "Average NTC"))) +
                guides(shape = guide_legend(title = "PGI Coefficient")) +
                xlab("Phenotype") +
                theme(axis.text.x = element_text(angle = 45,vjust=1,hjust=1),legend.position = "bottom",
                        axis.title.x = element_blank())+
                coord_flip()
        print(p)
        ggsave(paste0("/var/genetics/proj/within_family/within_family_project/processed/figures/fpgs_plots/fpgs_", dirpop, "_effects.png"), p, width = 10, height = 10)
}

fpgs_plot(df, "direct")
fpgs_plot(df, "population")

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