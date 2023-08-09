#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package')
import correlation_meta_functions as corr

pheno = "eversmoker"
all_cohorts = ["lifelines", "estonian_biobank", "ukb", "minn_twins", "hunt", "geisinger", "dutch_twin", "qimr", "finngen"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "finngen", processed_ss = "/disk/genetics/data/finngen/private/v1/processed/sumstats/ever_smoker", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "lifelines", processed_ss = "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_smk18", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "estonian_biobank", processed_ss = "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/SMOKING_ext/SMOKE_chr@_results", pheno = pheno, chrposid = False, format = False, avg_ntc = False)
corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/ever.smoked/ever.smoked", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "minn_twins", raw_ss = "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/ES_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/ES_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = True)
corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/smoEv/smoEv_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/smoEv/gz/smoEv_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "geisinger", raw_ss = "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.SMOKE_EVER.chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/OUTPUT/gz/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.SMOKE_EVER.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = False)
corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/EverSmoke/NTR_EverSmoke_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/EverSmoke/gz/NTR_EverSmoke_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/EverSmoker/EverSmoker_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/EverSmoker/gz/EverSmoker_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
