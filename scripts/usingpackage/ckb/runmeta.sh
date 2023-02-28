#!/usr/bin/bash

## script to run meta on ckb sumstats so that they're in the right format for correlate.py

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

for pheno in "height"
do
    python $scriptpath/run_metaanalysis.py \
    "/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/ckb/inputfiles_${pheno}.json" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ckb/meta_${pheno}" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/ckb/meta_${pheno}
done
