#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package/correlation_meta')
import correlation_meta_functions as corr

pheno = "depsymp"
all_cohorts = ["ukb", "moba", "hunt", "qimr", "fhs"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/depressive.symptoms/depressive.symptoms", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "moba", raw_ss = "/var/genetics/data/moba/private/v1/raw/sumstats/hdf5/depanx_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/moba/private/v1/processed/sumstats/gz/depanx_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = False)
corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/deprCat/deprCat_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/deprCat/gz/deprCat_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/Depression_Symptoms/DepSym_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/Depression_Symptoms/gz/DepSym_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "fhs", processed_ss = "/disk/genetics/data/fhs/public/v1/processed/sumstats/gwas/dep/chr@", pheno = pheno, chrposid = True, format = False, avg_ntc = False)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
