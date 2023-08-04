#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package')
import correlation_meta_functions as corr

pheno = "cpd"
all_cohorts = ["ukb", "minn_twins", "gs", "str", "hunt", "dutch_twin", "qimr", "fhs", "ft"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

# corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/cigarettes.per.day/cigarettes.per.day", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
# corr.get_correlations(cohort = "fhs", processed_ss = "/disk/genetics/data/fhs/public/v1/processed/sumstats/gwas/cpd/chr@", pheno = pheno, chrposid = True, format = False, avg_ntc = False)
# corr.get_correlations(cohort = "minn_twins", raw_ss = "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/CPD_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/CPD_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = True)
# corr.get_correlations(cohort = "gs", raw_ss = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/7/chr_*chr_clean.hdf5", processed_ss = "/var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/7/gz/chr_@.sumstatschr_clean", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "str", raw_ss = "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/cigsperday/cigsperday_chr*.hdf5", processed_ss = "/var/genetics/data/str/public/latest/processed/sumstats/fgwas/cigsperday/gz/cigsperday_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)
# corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/cigPerDay/cigPerDay_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/cigPerDay/gz/cigPerDay_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/CPD/NTR_CPD_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/CPD/gz/NTR_CPD_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/CPD/CPD_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/CPD/gz/CPD_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "ft", raw_ss = "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/cpd.chr*.hdf5", processed_ss = "/var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/gz/cpd.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
