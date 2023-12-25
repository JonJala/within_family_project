#!/usr/bin/bash

## ------------------------------------------------------------------------------------------------
## random-effects meta-analysis of correlation estimates
## ------------------------------------------------------------------------------------------------

import sys
sys.path.insert(1, '/var/genetics/proj/within_family/within_family_project/scripts/package/correlation_meta')
import correlation_meta_functions as corr

pheno = "height"
all_cohorts = ["botnia", "lifelines", "estonian_biobank", "ukb", "minn_twins", "gs", "moba", "str", "hunt", "geisinger", "dutch_twin", "qimr", "fhs", "finngen"]

## ------------------------------------------------------------------------------------------------
## calculate correlations for each cohort using correlate.py
## ------------------------------------------------------------------------------------------------

corr.get_correlations(cohort = "finngen", processed_ss = "/disk/genetics/data/finngen/private/v1/processed/sumstats/height", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "lifelines", processed_ss = "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_height18", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "estonian_biobank", processed_ss = "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/height/height_chr@_results", pheno = pheno, chrposid = False, format = False, avg_ntc = False)
corr.get_correlations(cohort = "ukb", processed_ss = "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/height/height", pheno = pheno, chrposid = False, format = False, avg_ntc = True)
corr.get_correlations(cohort = "fhs", processed_ss = "/disk/genetics/data/fhs/public/v1/processed/sumstats/gwas/height/chr@", pheno = pheno, chrposid = True, format = False, avg_ntc = False)
corr.get_correlations(cohort = "minn_twins", raw_ss = "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/Height_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/minn_twins/public/latest/processed/sumstats/fgwas/sumstats/gz/Height_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = True)
corr.get_correlations(cohort = "gs", raw_ss = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/5/chr_*chr_clean.hdf5", processed_ss = "/var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/5/gz/chr_@.sumstatschr_clean", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "moba", raw_ss = "/var/genetics/data/moba/private/v1/raw/sumstats/hdf5/ht_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/moba/private/v1/processed/sumstats/gz/ht_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = False)
corr.get_correlations(cohort = "str", raw_ss = "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/height/height_chr*.hdf5", processed_ss = "/var/genetics/data/str/public/latest/processed/sumstats/fgwas/height/gz/height_chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = True)
corr.get_correlations(cohort = "hunt", raw_ss = "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/height/height_chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/height/gz/height_chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "geisinger", raw_ss = "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.HEIGHT.std.chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/OUTPUT/gz/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.HEIGHT.std.chr@", pheno = pheno, chrposid = False, format = True, avg_ntc = False)
corr.get_correlations(cohort = "dutch_twin", raw_ss = "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Height/NTR_Height_CHR*.sumstats.hdf5", processed_ss = "/var/genetics/data/dutch_twin/public/latest/processed/sumstats/fgwas/Height/gz/NTR_Height_CHR@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "qimr", raw_ss = "/var/genetics/data/qimr/private/v1/raw/pgs/QIMR_FamilyGWAS/Height/Height_Chr*.sumstats.hdf5", processed_ss = "/var/genetics/data/qimr/private/v1/processed/pgs/QIMR_FamilyGWAS/Height/gz/Height_Chr@", pheno = pheno, chrposid = True, format = True, avg_ntc = False)
corr.get_correlations(cohort = "botnia", processed_ss = "/var/genetics/data/botnia_fam/private/latest/processed/sumstats/fgwas/5/chr_@", pheno = pheno, chrposid = True, format = False, avg_ntc = True)

## ------------------------------------------------------------------------------------------------
## compile and meta-analyze correlation estimates
## ------------------------------------------------------------------------------------------------

corr.compile_correlation_estimates(pheno, all_cohorts)
corr.metaanalyze_corrs(pheno)
