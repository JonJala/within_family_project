#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package/correlation_meta')
import correlation_meta_functions as corr

pheno = "cognition"
all_cohorts = ["lifelines", "ukb", "minn_twins", "gs", "str", "qimr", "ft"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "lifelines", processed_ss = "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_UNIQUE18", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/Cognitive.ability/Cognitive.ability", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "minn_twins", raw_ss = "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/IQ_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/IQ_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = True)
corr.get_correlations(cohort = "gs", raw_ss = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/8/chr_*chr_clean.hdf5", processed_ss = "/var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/8/gz/chr_@.sumstatschr_clean", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "str", raw_ss = "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/stdIQ/stdIQ_chr*.hdf5", processed_ss = "/var/genetics/data/str/public/latest/processed/sumstats/fgwas/stdIQ/gz/stdIQ_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)
corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/IQ/IQ_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/IQ/gz/IQ_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "ft", raw_ss = "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/IQ.chr*.hdf5", processed_ss = "/var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/gz/IQ.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
