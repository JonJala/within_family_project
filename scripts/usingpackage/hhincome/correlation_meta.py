#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package')
import correlation_meta_functions as corr

pheno = "hhincome"
all_cohorts = ["ukb", "str"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/household.income/household.income", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "str", raw_ss = "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/hhInc/hhInc_chr*.hdf5", processed_ss = "/var/genetics/data/str/public/latest/processed/sumstats/fgwas/hhInc/gz/hhInc_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
