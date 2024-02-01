#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run cross-trait genomic SEM and compile results
## ---------------------------------------------------------------------

library(data.table)
library(dplyr)
library(writexl)
library(stringr)

## ---------------------------------------------------------------------
## function to compile results
## ---------------------------------------------------------------------

compile_results <- function(phenotypes) {

    ## compile results table
    results_table <- data.frame(matrix(ncol = 9, nrow = 0))
    for (pheno1 in phenotypes) {
        pheno1_index <- which(phenotypes == pheno1)
        for (pheno2 in phenotypes) {
            pheno2_index <- which(phenotypes == pheno2)
            if (pheno2_index > pheno1_index) {
                results <- fread(paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/", pheno1, "_", pheno2, "/", pheno1, "_", pheno2, "_results.txt"))
                row <- c(pheno1, pheno2, results$value)
                results_table <- rbind(results_table, row)
            }
        }
    }
    
    ## format

    # rename columns
    colnames(results_table) <- c("pheno1", "pheno2", "corr1", "corr1_se", "corr2", "corr2_se", "corr_diff", "corr_diff_se", "z", "p")
    
    # format pheno names
    results_table <- results_table %>%
                        mutate(pheno1 = case_when(pheno1 %in% c("adhd", "bmi", "copd", "ea", "hdl") ~ toupper(pheno1),
                                pheno1 == "nonhdl" ~ "Non-HDL",
                                pheno1 == "fev" ~ "FEV1",
                                pheno1 == "agemenarche" ~ "Age-at-menarche",
                                pheno1 == "bps" ~ "BPS",
                                pheno1 == "bpd" ~ "BPD",
                                pheno1 == "cognition" ~ "Cognitive performance",
                                pheno1 == "depsymp" ~ "Depressive symptoms",
                                pheno1 == "eversmoker" ~ "Ever-smoker",
                                pheno1 == "dpw" ~ "Drinks-per-week",
                                pheno1 == "hayfever" ~ "Allergic rhinitis",
                                pheno1 == "health" ~ "Self-rated health",
                                pheno1 == "hhincome" ~ "Household income",
                                pheno1 == "swb" ~ "Subjective well-being",
                                pheno1 == "nchildren" ~ "Number of children",
                                pheno1 == "nearsight" ~ "Myopia",
                                pheno1 == "aud" ~ "Alcohol use disorder",
                                pheno1 == "cpd" ~ "Cigarettes per day",
                                pheno1 == "aafb" ~ "Age at first birth",
                                pheno1 == "morningperson" ~ "Morning person",
                                pheno1 %in% c("asthma", "cannabis", "depression", "eczema", "extraversion", "height", "income", "migraine", "neuroticism", "nchildren", "agemenarche", "eczema", "hayfever", "eversmoker", "morningperson", "asthma", "nearsight", "height", "migraine", "income", "extraversion", "hypertension") ~ str_to_title(pheno1)),
                        pheno2 = case_when(pheno2 %in% c("adhd", "bmi", "copd", "ea", "hdl") ~ toupper(pheno2),
                                pheno2 == "nonhdl" ~ "Non-HDL",
                                pheno2 == "fev" ~ "FEV1",
                                pheno2 == "agemenarche" ~ "Age-at-menarche",
                                pheno2 == "bps" ~ "BPS",
                                pheno2 == "bpd" ~ "BPD",
                                pheno2 == "cognition" ~ "Cognitive performance",
                                pheno2 == "depsymp" ~ "Depressive symptoms",
                                pheno2 == "eversmoker" ~ "Ever-smoker",
                                pheno2 == "dpw" ~ "Drinks-per-week",
                                pheno2 == "hayfever" ~ "Allergic rhinitis",
                                pheno2 == "health" ~ "Self-rated health",
                                pheno2 == "hhincome" ~ "Household income",
                                pheno2 == "swb" ~ "Subjective well-being",
                                pheno2 == "nchildren" ~ "Number of children",
                                pheno2 == "nearsight" ~ "Myopia",
                                pheno2 == "aud" ~ "Alcohol use disorder",
                                pheno2 == "cpd" ~ "Cigarettes per day",
                                pheno2 == "aafb" ~ "Age at first birth",
                                pheno2 == "morningperson" ~ "Morning person",
                                pheno2 %in% c("asthma", "cannabis", "depression", "eczema", "extraversion", "height", "income", "migraine", "neuroticism", "nchildren", "agemenarche", "eczema", "hayfever", "eversmoker", "morningperson", "asthma", "nearsight", "height", "migraine", "income", "extraversion", "hypertension") ~ str_to_title(pheno2)))
    
    # add -log10(p) and adjusted pval column
    results_table[,3:ncol(results_table)] <- sapply(results_table[,3:ncol(results_table)], as.numeric) # exclude first two columns (phenotypes)
    results_table <- results_table %>%
                        mutate(log_p = -log10(p),
                                p_adj = p.adjust(p, method='BH'))
    results_table <- results_table[order(results_table$log_p, decreasing = TRUE),] # arrange in order of -log10(p)
    
    # write to file
    write_xlsx(results_table, "/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait/cross_trait_results.xlsx")

}

## ---------------------------------------------------------------------
## run cross-trait genomicSEM
## ---------------------------------------------------------------------

source("/var/genetics/proj/within_family/within_family_project/scripts/genomic_sem/genomic_sem_functions.R")

ldsc <- "/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
ss_basepath <- "/var/genetics/proj/within_family/within_family_project/processed/package_output/"

phenotypes <- c("aafb", "adhd", "agemenarche", "asthma", "aud", "bmi", "bpd", "bps", "cannabis", "cognition", "copd", "cpd", "depression",
                 "depsymp", "dpw", "ea", "eczema", "eversmoker", "extraversion", "fev", "hayfever", "hdl", "health", "height", "hhincome", "hypertension", "income", 
                 "migraine", "morningperson", "nchildren", "nearsight", "neuroticism", "nonhdl", "swb")

# for (pheno1 in phenotypes) {
#     pheno1_index <- which(phenotypes == pheno1)
#     for (pheno2 in phenotypes) {
#         pheno2_index <- which(phenotypes == pheno2)
#         if (pheno2_index > pheno1_index) {
#             run_cross_trait(pheno1 = pheno1,
#                             pheno2 = pheno2,
#                             pheno1_direct = paste0(ss_basepath, pheno1, "/direct.sumstats.gz"),
#                             pheno1_pop = paste0(ss_basepath, pheno1, "/population.sumstats.gz"),
#                             pheno2_direct = paste0(ss_basepath, pheno2, "/direct.sumstats.gz"),
#                             pheno2_pop = paste0(ss_basepath, pheno2, "/population.sumstats.gz"),
#                             ldsc = ldsc,
#                             analyze_results = TRUE)
#         }
#     }
# }

## compile results
compile_results(phenotypes)
