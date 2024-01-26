#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run genomic SEM for single trait
## ---------------------------------------------------------------------

library(data.table)
library(readxl)
library(writexl)
library(dplyr)
library(stringr)

source("/var/genetics/proj/within_family/within_family_project/scripts/genomic_sem/genomic_sem_functions.R")

compile_h2_results = TRUE # results for p-values associated with difference between direct and pop h2 for each trait

ldsc <- "/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
ss_basepath <- "/var/genetics/proj/within_family/within_family_project/processed/package_output/"

phenotypes <- c("aafb", "adhd", "agemenarche", "asthma", "aud", "bmi", "bpd", "bps", "cannabis", "cognition", "copd", "cpd", "depression",
                 "depsymp", "dpw", "ea", "eczema", "eversmoker", "extraversion", "fev", "hayfever", "hdl", "health", "height", "hhincome", "hypertension", "income", 
                 "migraine", "morningperson", "nchildren", "nearsight", "neuroticism", "nonhdl", "swb")

if (compile_h2_results) {
    h2_results_table <- data.frame(matrix(ncol = 9, nrow = 0))
}

for (pheno in phenotypes) {

    print(paste0("Starting ", pheno))

    if (pheno == "aud") {
        ref_ss <- "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/dpw_ref/dpw_ref.sumstats.gz"
    } else if (pheno == "copd") {
        ref_ss <- "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/fev_ref/fev_ref.sumstats.gz"
    } else if (pheno == "hypertension") {
        ref_ss <- "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bps_ref/bps_ref.sumstats.gz"
    } else {
        ref_ss <- paste0("/var/genetics/proj/within_family/within_family_project/processed/reference_samples/", pheno, "_ref/", pheno, "_ref.sumstats.gz")
    }

    # ## munge
    # munge_sumstats(paste0(meta_ss="/var/genetics/proj/within_family/within_family_project/processed/package_output/", pheno, "/meta.nfilter.sumstats.gz"),
    #            outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/package_output/", pheno, "/"),
    #            trait.names=c("direct", "population"))

    ## run genomicSEM
    # if (pheno == "migraine" || pheno == "cannabis") {
    #     run_single_trait(pheno = pheno,
    #                 direct_ss = paste0(ss_basepath, pheno, "/direct.sumstats.gz"),
    #                 pop_ss = paste0(ss_basepath, pheno, "/population.sumstats.gz"),
    #                 ldsc = ldsc,
    #                 h2_results = compile_h2_results)
    # } else {
    #     run_single_trait(pheno = pheno,
    #                 direct_ss = paste0(ss_basepath, pheno, "/direct.sumstats.gz"),
    #                 pop_ss = paste0(ss_basepath, pheno, "/population.sumstats.gz"),
    #                 ref_ss = ref_ss,
    #                 ldsc = ldsc,
    #                 h2_results = compile_h2_results)
    # }

    if (compile_h2_results) {
        h2_results <- fread(paste0("/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/", pheno, "/h2_results_", pheno, ".txt"))
        h2_results_table <- rbind(h2_results_table, c(pheno, h2_results$value))
    }

    print(paste0("Finished with ", pheno))

}

if (compile_h2_results) {
    
    # rename columns
    colnames(h2_results_table) <- c("phenotype", "direct_h2", "direct_h2_se", "pop_h2", "pop_h2_se", "h2_diff", "h2_diff_se", "z", "p")

    # format pheno names
    h2_results_table <- h2_results_table %>%
                        mutate(phenotype = case_when(phenotype %in% c("adhd", "bmi", "copd", "ea", "hdl") ~ toupper(phenotype),
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
                                phenotype %in% c("asthma", "cannabis", "depression", "eczema", "extraversion", "height", "income", "migraine", "neuroticism", "nchildren", "agemenarche", "eczema", "hayfever", "eversmoker", "morningperson", "asthma", "nearsight", "height", "migraine", "income", "extraversion", "hypertension") ~ str_to_title(phenotype)))

    # convert to numeric
    h2_results_table[2:ncol(h2_results_table)] <- lapply(h2_results_table[2:ncol(h2_results_table)], as.numeric) # exclude pheno col

    # put SEs in brackets next to each value
    h2_results_table <- h2_results_table %>%
                            mutate(direct_h2 = paste0(round(direct_h2, 3), " (", round(direct_h2_se, 3), ")"),
                                    pop_h2 = paste0(round(pop_h2, 3), " (", round(pop_h2_se, 3), ")"),
                                    h2_diff = paste0(round(h2_diff, 3), " (", round(h2_diff_se, 3), ")"))
    h2_results_table <- h2_results_table %>%
                            select(-c(direct_h2_se, pop_h2_se, h2_diff_se))                                

    # add -log10(p) column
    h2_results_table <- h2_results_table %>%
                            mutate(log_p = -log10(p))
    h2_results_table <- h2_results_table[order(h2_results_table$log_p, decreasing = TRUE),] # arrange in order of -log10(p)

    # write to file
    write_xlsx(h2_results_table, "/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/h2_diff_results.xlsx")

}

