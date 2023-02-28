#!/usr/bin/bash

act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
ckb_ld_chr="/var/genetics/data/ckb/private/v1/processed/ld_scores/snipar_generated"
PYTHONPATH="/var/genetics/code/snipar/SNIPar"

source /var/genetics/code/snipar/snipar_venv/bin/activate

for pheno in "height"
do
    /var/genetics/code/snipar/SNIPar/snipar/scripts/correlate.py  /var/genetics/proj/within_family/within_family_project/processed/package_output/ckb/meta_${pheno} \
    /var/genetics/proj/within_family/within_family_project/processed/package_output/ckb/${pheno}_marginal \
    --ldscores ${ckb_ld_chr}/@
done