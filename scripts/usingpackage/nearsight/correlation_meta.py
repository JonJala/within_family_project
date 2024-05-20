#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package/correlation_meta')
import correlation_meta_functions as corr

pheno = "nearsight"
all_cohorts = ["estonian_biobank", "ukb", "ipsych"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "estonian_biobank", processed_ss = "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/nearsightedness_usual_ext/nearsightedness_usual_chr@_results", pheno = pheno, chrposid = False, format = False, avg_ntc = False)
corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/NEARSIGHTED/NEARSIGHTED", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "ipsych", processed_ss = "/disk/genetics/data/ipsych/public/v2/processed/sumstats/sumstats_nearsightedness_export_plinkfiltered", pheno = pheno, chrposid = True, format = False, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
