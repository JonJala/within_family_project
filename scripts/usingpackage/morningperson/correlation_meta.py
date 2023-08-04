#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package')
import correlation_meta_functions as corr

pheno = "morningperson"
all_cohorts = ["ukb", "dutch_twin"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/morning.person/morning.person", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/MorningP/NTR_MorningP_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/MorningP/gz/NTR_MorningP_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
