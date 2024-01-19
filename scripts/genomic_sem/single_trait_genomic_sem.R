#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run genomic SEM for single trait
## ---------------------------------------------------------------------

source("/var/genetics/proj/within_family/within_family_project/scripts/genomic_sem/genomic_sem_functions.R")

ldsc <- "/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
ss_basepath <- "/var/genetics/proj/within_family/within_family_project/processed/package_output/"

phenotypes <- c("aafb", "adhd", "agemenarche", "asthma", "aud", "bmi", "bpd", "bps", "cannabis", "cognition", "copd", "cpd", "depression",
                 "depsymp", "dpw", "ea", "eczema", "eversmoker", "extraversion", "fev", "hayfever", "hdl", "health", "height", "hhincome", "hypertension", "income", 
                 "migraine", "morningperson", "nchildren", "nearsight", "neuroticism", "nonhdl", "swb")

for (pheno in phenotypes) {

    print(paste0("Starting ", pheno))

    munge_sumstats(paste0(meta_ss="/var/genetics/proj/within_family/within_family_project/processed/package_output/", pheno, "/meta.nfilter.sumstats.gz"),
               outpath=paste0("/var/genetics/proj/within_family/within_family_project/processed/package_output/", pheno, "/"),
               trait.names=c("direct", "population"))

    if (pheno == "aud") {
        ref_ss <- "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/dpw_ref/dpw_ref.sumstats.gz"
    } else if (pheno == "copd") {
        ref_ss <- "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/fev_ref/fev_ref.sumstats.gz"
    } else if (pheno == "hypertension") {
        ref_ss <- "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bps_ref/bps_ref.sumstats.gz"
    } else {
        ref_ss <- paste0("/var/genetics/proj/within_family/within_family_project/processed/reference_samples/", pheno, "_ref/", pheno, "_ref.sumstats.gz")
    }

    if (pheno == "migraine") { ## no reference sample
        run_single_trait(pheno = pheno,
                    direct_ss = paste0(ss_basepath, pheno, "/direct.sumstats.gz"),
                    pop_ss = paste0(ss_basepath, pheno, "/population.sumstats.gz"),
                    ldsc = ldsc)
    } else {
        run_single_trait(pheno = pheno,
                    direct_ss = paste0(ss_basepath, pheno, "/direct.sumstats.gz"),
                    pop_ss = paste0(ss_basepath, pheno, "/population.sumstats.gz"),
                    ref_ss = ref_ss,
                    ldsc = ldsc)
    }

    print(paste0("Finished with ", pheno))

}

