#!/usr/bin/bash

basepath="/var/genetics/proj/within_family/within_family_project/scripts/package/h2_meta"
pheno="ea"
cohorts="ukb str moba minn_twins lifelines hunt gs geisinger ft estonian_biobank dutch_twin qimr ipsych"

## calculate direct and pop h2 for each cohort
bash ${basepath}/calculate_h2.sh ${pheno} "${cohorts}"

## compile h2 estimates into excel spreadsheet
python ${basepath}/compile_h2_estimates.py \
    --pheno ${pheno} \
    --cohorts "${cohorts}"

## meta-analyze h2 estimates and create forest plots
Rscript ${basepath}/metaanalyze_h2.r \
    --pheno ${pheno} \
    --cohorts "${cohorts}"
