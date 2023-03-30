#!/usr/bin/bash

## run correlate.py on ckb sumstats

source /var/genetics/proj/within_family/snipar_venv/bin/activate

processed="/var/genetics/proj/within_family/within_family_project/processed/ckb"

for pheno in "asthma_all_chr" "bin_depressive_symptoms_all_chr" "cpd_M_chr" "edu_years_all_chr" "ever_smoker_all_chr" "fev1_mean_all_chr" "ln_drinks_all_chr" "mena_age_F_chr" "num_children_all_chr" "residue_bmi_calc_all_chr" "residue_dbp_mean_all_chr" "residue_sbp_mean_all_chr" "residue_standing_height_mm_all_chr" "satisfaction_level_all_chr" "self_rated_health_all_chr"
do
    PYTHONPATH="/var/genetics/proj/within_family/snipar_simulate" /var/genetics/proj/within_family/snipar_simulate/snipar/scripts/correlate.py /var/genetics/data/ckb/private/v1/raw/sumstats/Dec_2022/${pheno}@ \
    ${processed}/marginal_corrs/${pheno}_marginal \
    --ldscores /disk/genetics3/data_dirs/ckb/private/v1/raw/ld_scores/snipar_generated/ldscores/chr_@
done

mv ${processed}/marginal_corrs/asthma_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/asthma_marginal_corrs.txt
mv ${processed}/marginal_corrs/bin_depressive_symptoms_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/depsymp_marginal_corrs.txt
mv ${processed}/marginal_corrs/cpd_M_chr_marginal_corrs.txt ${processed}/marginal_corrs/cpd_marginal_corrs.txt
mv ${processed}/marginal_corrs/edu_years_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/ea_marginal_corrs.txt
mv ${processed}/marginal_corrs/ever_smoker_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/eversmoker_marginal_corrs.txt
mv ${processed}/marginal_corrs/fev1_mean_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/fev_marginal_corrs.txt
mv ${processed}/marginal_corrs/ln_drinks_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/dpw_marginal_corrs.txt
mv ${processed}/marginal_corrs/mena_age_F_chr_marginal_corrs.txt ${processed}/marginal_corrs/agemenarche_marginal_corrs.txt
mv ${processed}/marginal_corrs/num_children_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/nchildren_marginal_corrs.txt
mv ${processed}/marginal_corrs/residue_bmi_calc_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/bmi_marginal_corrs.txt
mv ${processed}/marginal_corrs/residue_dbp_mean_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/bpd_marginal_corrs.txt
mv ${processed}/marginal_corrs/residue_sbp_mean_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/bps_marginal_corrs.txt
mv ${processed}/marginal_corrs/residue_standing_height_mm_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/height_marginal_corrs.txt
mv ${processed}/marginal_corrs/satisfaction_level_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/swb_marginal_corrs.txt
mv ${processed}/marginal_corrs/self_rated_health_all_chr_marginal_corrs.txt ${processed}/marginal_corrs/health_marginal_corrs.txt
