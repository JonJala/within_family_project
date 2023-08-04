#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package')
import correlation_meta_functions as corr

pheno = "swb"
all_cohorts = ["ukb", "minn_twins", "str", "hunt", "dutch_twin", "qimr", "ft"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/subjective.well.being/subjective.well.being", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "minn_twins", raw_ss = "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/SWB_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/SWB_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = True)
corr.get_correlations(cohort = "str", raw_ss = "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SWB/SWB_chr*.hdf5", processed_ss = "/var/genetics/data/str/public/latest/processed/sumstats/fgwas/SWB/gz/SWB_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)
corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/wellbeing/wellbeing_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/wellbeing/gz/wellbeing_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/SatisfactionWithLife/NTR_SatisfactionWithLife_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/SatisfactionWithLife/gz/NTR_SatisfactionWithLife_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/Wellbeing/Wellbeing_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/Wellbeing/gz/Wellbeing_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "ft", raw_ss = "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/wellbeing.chr*.hdf5", processed_ss = "/var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/gz/wellbeing.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
