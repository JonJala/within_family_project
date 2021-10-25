#!/usr/bin/bash
### Run the easyqc pipeline

#####################
# ====== UKB ====== #
#####################


# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/13/chr_*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/bmi" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     -bim_chromosome 99 \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz"


#####################
# ==== MT ========= #
#####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/BMI_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/bmi" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz" \
#     --cptid \
#     --toest "direct_population"

# 1.0932 (0.785)