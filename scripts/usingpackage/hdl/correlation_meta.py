#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package')
import correlation_meta_functions as corr

pheno = "hdl"
all_cohorts = ["botnia", "lifelines", "ft", "ukb", "gs", "hunt", "geisinger", "dutch_twin", "qimr", "fhs"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

# corr.get_correlations(cohort = "lifelines", processed_ss = "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_HDC18", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
# corr.get_correlations(cohort = "ft", raw_ss = "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/HDL.chr*.hdf5", processed_ss = "/var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/gz/HDL.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)
# corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/BL_HDL/BL_HDL", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
# corr.get_correlations(cohort = "fhs", processed_ss = "/var/genetics/data/fhs/public/v1/processed/sumstats/gwas/hdl/chr@", pheno = pheno, chrposid = True, format = False, avg_ntc = False)
# corr.get_correlations(cohort = "gs", raw_ss = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/3/chr_*chr_clean.hdf5", processed_ss = "/var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/3/gz/chr_@.sumstatschr_clean", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/hdl/hdl_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/hdl/gz/hdl_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "geisinger", raw_ss = "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.HDL.all.chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/OUTPUT/gz/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.HDL.all.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/HDL/NTR_HDL_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/HDL/gz/NTR_HDL_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/HDL/HDL_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/HDL/gz/HDL_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
# corr.get_correlations(cohort = "botnia", processed_ss = "/var/genetics/data/botnia_fam/private/latest/processed/sumstats/fgwas/3/chr_@", pheno = pheno, chrposid = True, format = False, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
