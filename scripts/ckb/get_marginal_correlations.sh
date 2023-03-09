#!/usr/bin/bash

## run correlate.py on ckb sumstats

source /var/genetics/proj/within_family/snipar_venv/bin/activate

for pheno in "asthma_all_chr" "bin_depressive_symptoms_all_chr" "cpd_M_chr" "edu_years_all_chr" "ever_smoker_all_chr" "fev1_mean_all_chr" "ln_drinks_all_chr" "mena_age_F_chr" "num_children_all_chr" "residue_bmi_calc_all_chr" "residue_dbp_mean_all_chr" "residue_sbp_mean_all_chr" "residue_standing_height_mm_all_chr" "satisfaction_level_all_chr" "self_rated_health_all_chr"
do
    PYTHONPATH="/var/genetics/proj/within_family/snipar_effect_reg" /var/genetics/proj/within_family/snipar_effect_reg/snipar/scripts/correlate.py /var/genetics/data/ckb/private/v1/raw/sumstats/Dec_2022/${pheno}@ \
    /var/genetics/proj/within_family/within_family_project/processed/ckb/${pheno}_marginal \
    --ldscores /disk/genetics3/data_dirs/ckb/private/v1/raw/ld_scores/snipar_generated/ldscores/chr_@
done