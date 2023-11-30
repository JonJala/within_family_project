#!/usr/bin/bash

ldscpath="/var/genetics/proj/within_family/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"

source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

## arguments
pheno=$1
cohorts=$2

## loop over cohorts
for cohort in ${cohorts}
do

    echo "Starting ${cohort}"

    echo "Munging!!"
    ${ldscpath}/munge_sumstats.py \
    --sumstats ${within_family_path}/processed/qc/${cohort}/${pheno}/CLEANED.out.gz \
    --out ${within_family_path}/processed/qc/${cohort}/${pheno}/populationmunged \
    --N-col n_population --p PVAL_population --signed-sumstats z_population,0

    ${ldscpath}/munge_sumstats.py \
    --sumstats ${within_family_path}/processed/qc/${cohort}/${pheno}/CLEANED.out.gz \
    --out ${within_family_path}/processed/qc/${cohort}/${pheno}/directmunged \
    --N-col n_direct --p PVAL_direct --signed-sumstats z_direct,0

    echo "Calculating direct h2"
    ${ldscpath}/ldsc.py \
    --h2 ${within_family_path}/processed/qc/${cohort}/${pheno}/directmunged.sumstats.gz \
    --ref-ld-chr ${eur_w_ld_chr} \
    --w-ld-chr ${eur_w_ld_chr} \
    --out ${within_family_path}/processed/qc/${cohort}/${pheno}/direct_h2

    echo "Calculating population h2"
    ${ldscpath}/ldsc.py \
    --h2 ${within_family_path}/processed/qc/${cohort}/${pheno}/populationmunged.sumstats.gz \
    --ref-ld-chr ${eur_w_ld_chr} \
    --w-ld-chr ${eur_w_ld_chr} \
    --out ${within_family_path}/processed/qc/${cohort}/${pheno}/population_h2

done