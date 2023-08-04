#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package')
import correlation_meta_functions as corr

pheno = "neuroticism"
all_cohorts = ["ukb", "minn_twins", "gs", "hunt", "dutch_twin", "qimr", "ft"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/Neuroticism/Neuroticism", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "minn_twins", raw_ss = "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/STRESS_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/STRESS_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = True)
corr.get_correlations(cohort = "gs", raw_ss = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/13/chr_*chr_clean.hdf5", processed_ss = "/var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/13/gz/chr_@.sumstatschr_clean", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/neuroticism/neuroticism_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/neuroticism/gz/neuroticism_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Neuroticism/NTR_Neuroticism_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/Neuroticism/gz/NTR_Neuroticism_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/Neuroticism/Neuroticism_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/Neuroticism/gz/Neuroticism_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "ft", raw_ss = "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/neuroticism.chr*.hdf5", processed_ss = "/var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/gz/neuroticism.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
