#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run cross-trait genomic SEM
## ---------------------------------------------------------------------

source("/var/genetics/proj/within_family/within_family_project/scripts/genomic_sem/genomic_sem_functions.R")

ldsc <- "/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
ss_basepath <- "/var/genetics/proj/within_family/within_family_project/processed/package_output/"

phenotypes <- c("aafb", "adhd", "agemenarche", "asthma", "aud", "bmi", "bpd", "bps", "cannabis", "cognition", "copd", "cpd", "depression",
                 "depsymp", "dpw", "ea", "eczema", "eversmoker", "extraversion", "fev", "hayfever", "hdl", "health", "height", "hhincome", "hypertension", "income", 
                 "migraine", "morningperson", "nchildren", "nearsight", "neuroticism", "nonhdl", "swb")

for (pheno1 in phenotypes) {
    pheno1_index = which(phenotypes == pheno1)
    for (pheno2 in phenotypes) {
        pheno2_index = which(phenotypes == pheno2)
        if (pheno2_index > pheno1_index) {
            run_cross_trait(pheno1 = pheno1,
                            pheno2 = pheno2,
                            pheno1_direct = paste0(ss_basepath, pheno1, "/directmunged.sumstats.gz"),
                            pheno1_pop = paste0(ss_basepath, pheno1, "/populationmunged.sumstats.gz"),
                            pheno2_direct = paste0(ss_basepath, pheno2, "/directmunged.sumstats.gz"),
                            pheno2_pop = paste0(ss_basepath, pheno2, "/populationmunged.sumstats.gz"),
                            ldsc = ldsc,
                            analyze_results = TRUE)
        }
    }
}