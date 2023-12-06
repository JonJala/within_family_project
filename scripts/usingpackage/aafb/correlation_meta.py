#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package/correlation_meta')
import correlation_meta_functions as corr

pheno = "aafb"
all_cohorts = ["ukb", "estonian_biobank", "hunt", "qimr", "finngen"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "finngen", processed_ss = "/var/genetics/data/finngen/private/v1/processed/sumstats/aafb_women", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "estonian_biobank", processed_ss = "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/AGE-First-BIRTH-ext/AGE_chr@_results", pheno = pheno, chrposid = False, format = False, avg_ntc = False)
corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/AAFB/AAFB", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/AgeFirstBirth/AgeFirstBirth_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/AgeFirstBirth/gz/AgeFirstBirth_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/AgeFirstBirth/AFB_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/AgeFirstBirth/gz/AFB_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
