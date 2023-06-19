#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/snipar_simulate/snipar"
basepath="/var/genetics/proj/within_family/within_family_project/scripts/package"
pheno="ea"
sumstats="/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/EA/EA"
# cohorts="ukb str moba minn_twins lifelines hunt gs geisinger ft estonian_biobank dutch_twin botnia qimr"
cohorts="ukb"

source /var/genetics/proj/within_family/snipar_venv/bin/activate

## calculate direct-pop correlation for each cohort
for cohort in ${cohorts}
do
    ${snipar_path}/scripts/correlate.py ${sumstats} \
        ${within_family_path}/processed/qc/${cohort}/${pheno}/marginal_correlations \
        --ldscores /disk/genetics/ukb/alextisyoung/hapmap3/ldscores/@
done

# ## compile correlation estimates into excel spreadsheet
# python ${basepath}/compile_correlation_estimates.py \
#     --pheno ${pheno} \
#     --cohorts "${cohorts}"

