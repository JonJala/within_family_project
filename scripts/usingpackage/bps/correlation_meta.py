#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package')
import correlation_meta_functions as corr

pheno = "bps"
all_cohorts = ["ukb", "minn_twins", "gs", "botnia", "hunt", "geisinger", "dutch_twin", "fhs", "ft"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

# corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/BPsys/BPsys", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
# corr.get_correlations(cohort = "fhs", processed_ss = "/disk/genetics/data/fhs/public/v1/processed/sumstats/gwas/sbp/chr@", pheno = pheno, chrposid = True, format = False, avg_ntc = False)
# corr.get_correlations(cohort = "minn_twins", raw_ss = "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/BPS_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/BPS_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = True)
# corr.get_correlations(cohort = "gs", raw_ss = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/11/chr_*chr_clean.hdf5", processed_ss = "/var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/11/gz/chr_@.sumstatschr_clean", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/sbp/sbp_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/sbp/gz/sbp_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "geisinger", raw_ss = "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.SBP.all.chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/OUTPUT/gz/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.SBP.all.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/SBP/NTR_SBP_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/SBP/gz/NTR_SBP_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "botnia", processed_ss = "/var/genetics/data/botnia_fam/private/latest/processed/sumstats/fgwas/8/chr_@", pheno = pheno, chrposid = True, format = False, avg_ntc = True)
corr.get_correlations(cohort = "ft", raw_ss = "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/SBP.chr*.hdf5", processed_ss = "/var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/gz/SBP.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
