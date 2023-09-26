#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/health/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/health/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/health/meta.log

