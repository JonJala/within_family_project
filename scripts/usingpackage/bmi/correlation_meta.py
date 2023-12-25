#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package/correlation_meta')
import correlation_meta_functions as corr

pheno = "bmi"
all_cohorts = ["lifelines", "estonian_biobank", "ukb", "minn_twins", "gs", "moba", "str", "hunt", "geisinger", "dutch_twin", "qimr", "fhs", "finngen"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "finngen", processed_ss = "/disk/genetics/data/finngen/private/v1/processed/sumstats/bmi", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "lifelines", processed_ss = "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_bmi18", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "estonian_biobank", processed_ss = "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/BMI/BMI_chr@_results", pheno = pheno, chrposid = False, format = False, avg_ntc = False)
corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/BMI/BMI", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "fhs", processed_ss = "/disk/genetics/data/fhs/public/v1/processed/sumstats/gwas/bmi/chr@", pheno = pheno, chrposid = True, format = False, avg_ntc = False)
corr.get_correlations(cohort = "minn_twins", raw_ss = "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/BMI_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/BMI_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = True)
corr.get_correlations(cohort = "gs", raw_ss = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/6/chr_*.sumstatschr_clean.hdf5", processed_ss = "/var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/6/gz/chr_@.sumstatschr_clean", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "moba", raw_ss = "/var/genetics/data/moba/private/v1/raw/sumstats/hdf5/bmi_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/moba/private/v1/processed/sumstats/gz/bmi_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = False)
corr.get_correlations(cohort = "str", raw_ss = "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/bmi/bmi_chr*.hdf5", processed_ss = "/var/genetics/data/str/public/latest/processed/sumstats/fgwas/bmi/gz/bmi_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)
corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bmi/bmi_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/bmi/gz/bmi_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "geisinger", raw_ss = "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.BMI.chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/OUTPUT/gz/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.BMI.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = False)
corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/BMI/NTR_BMI_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/BMI/gz/NTR_BMI_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/BMI/BMI_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/BMI/gz/BMI_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
