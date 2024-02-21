#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: compile correlation matrix (ST5)
## ---------------------------------------------------------------------

list.of.packages <- c("data.table", "tidyr", "dplyr", "tidyverse", "writexl")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages, repos = "http://cran.rstudio.com/")
lapply(list.of.packages, library, character.only = TRUE)

## ---------------------------------------------------------------------
## get genetic correlations from genomicSEM results
## ---------------------------------------------------------------------

basepath <- "/var/genetics/proj/within_family/within_family_project/processed/genomic_sem/cross_trait"

phenotypes <- c("aafb", "adhd", "agemenarche", "asthma", "aud", "bmi", "bpd", "bps", "cannabis", "cognition", "copd", "cpd", "depression",
                 "depsymp", "dpw", "ea", "eczema", "eversmoker", "extraversion", "fev", "hayfever", "hdl", "health", "height", "hhincome", "hypertension", "income", 
                 "migraine", "morningperson", "nchildren", "nearsight", "neuroticism", "nonhdl", "swb")

direct_rgs_table <- data.table()
pop_rgs_table <- data.table()

for (pheno1 in phenotypes) {

    print(paste0("Starting ",pheno1))
    pheno1_index <- which(phenotypes == pheno1)

    ## create empty vectors to store rgs
    rgs_direct <- rep(NA, length(phenotypes))
    rgs_pop <- rep(NA, length(phenotypes))

    for (pheno2 in phenotypes) {

        pheno2_index <- which(phenotypes == pheno2)

        if (pheno2_index > pheno1_index) {

            log <- readLines(paste0(basepath, "/", pheno1, "_", pheno2, "/", pheno1, "_", pheno2, "_ldsc.log"))
            direct_rg_line <- grep(paste0("Genetic Correlation between ", pheno1, "_direct and ", pheno2, "_direct:"), log, value = T)
            pop_rg_line <- grep(paste0("Genetic Correlation between ", pheno1, "_pop and ", pheno2, "_pop:"), log, value = T)

            if (length(direct_rg_line) > 0) {
                rg_direct <- as.numeric(strsplit(strsplit(direct_rg_line, ": ")[[1]][2], " \\(")[[1]][1])
                rg_direct_se <- as.numeric(strsplit(strsplit(direct_rg_line, "\\(")[[1]][2], "\\)")[[1]][1])
            } else {
                rg_direct <- NA
                rg_direct_se <- NA
            }

            if (length(pop_rg_line) > 0) {
                rg_pop <- as.numeric(strsplit(strsplit(pop_rg_line, ": ")[[1]][2], " \\(")[[1]][1])
                rg_pop_se <- as.numeric(strsplit(strsplit(pop_rg_line, "\\(")[[1]][2], "\\)")[[1]][1])
            } else {
                rg_pop <- NA
                rg_pop_se <- NA
            }

            rgs_direct[pheno2_index] <- paste0(rg_direct, " (", rg_direct_se, ")")
            rgs_pop[pheno2_index] <- paste0(rg_pop, " (", rg_pop_se, ")")

        } else if (pheno1 == pheno2) {
            rgs_direct[pheno2_index] <- 1
            rgs_pop[pheno2_index] <- 1
        }

    }

    direct_rgs_table <- cbind(direct_rgs_table, rgs_direct)
    pop_rgs_table <- cbind(pop_rgs_table, rgs_pop)

}

direct_rgs_table <- t(direct_rgs_table) # transpose so that direct rgs are upper triangle

rgs_table <- copy(pop_rgs_table)
colnames(rgs_table) <- phenotypes
rownames(rgs_table) <- phenotypes

for (i in 1:nrow(rgs_table)) {
    for (j in 1:ncol(rgs_table)) {
        if (i < j) {
            rg <- direct_rgs_table[[i,j]]
            rgs_table[[i,j]] <- rg
        }
    }
}

write_xlsx(rgs_table, path = "/var/genetics/proj/within_family/within_family_project/processed/package_output/direct_population_rg_matrix.xlsx", col_names = T)
