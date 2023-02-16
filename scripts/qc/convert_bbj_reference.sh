#!/usr/bin/bash

### add n column and munge bbj sumstats for bmi, height, and hdl

ldsc_path="/var/genetics/tools/ldsc/ldsc"
act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
pyenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"

## add n column
python /var/genetics/proj/within_family/within_family_project/scripts/qc/bbj_ref_add_n.py

## munge

# Activating ldsc environment
source ${act} ${pyenv}

# munge bmi sumstats

for pheno in "bmi" "height" "hdl"
do

    echo ${pheno}

    ldsc_ref="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bbj_ref/${pheno}_ref/${pheno}_ref_with_n.txt.gz"
    ref_out="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bbj_ref/${pheno}_ref/${pheno}_ref"

    python ${ldsc_path}/munge_sumstats.py \
        --sumstats ${ldsc_ref} \
        --out ${ref_out} \
        --signed-sumstats BETA,0 --a1 ALLELE1 --a2 ALLELE0 --p P_BOLT_LMM_INF

done