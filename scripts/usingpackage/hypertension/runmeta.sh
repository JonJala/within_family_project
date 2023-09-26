#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/hypertension/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/hypertension/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/hypertension/meta.log
