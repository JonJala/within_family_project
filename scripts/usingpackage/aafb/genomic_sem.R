#!/usr/bin/env Rscript

## ---------------------------------------------------------------------
## description: run genomic SEM for single trait
## ---------------------------------------------------------------------

source("/var/genetics/proj/within_family/within_family_project/scripts/package/genomic_sem/genomic_sem_functions.R")

ldsc <- "/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
ss_basepath <- "/var/genetics/proj/within_family/within_family_project/processed/package_output/"

pheno <- "aafb"
ref_ss <- "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/aafb_ref/aafb_ref.sumstats.gz"

munge_sumstats(meta_ss="/var/genetics/proj/within_family/within_family_project/processed/package_output/aafb/meta.nfilter.sumstats.gz",
               outpath="/var/genetics/proj/within_family/within_family_project/processed/package_output/aafb/",
               trait.names=c("aafb_direct", "aafb_population"))

# run_single_trait(pheno = pheno,
#                 direct_ss = paste0(ss_basepath, pheno, "/directmunged.sumstats.gz"),
#                 pop_ss = paste0(ss_basepath, pheno, "/populationmunged.sumstats.gz"),
#                 ref_ss = ref_ss,
#                 ldsc = ldsc)
