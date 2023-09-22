#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# Base
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/eversmoker/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/eversmoker/meta" | tee "/var/genetics/proj/within_family/within_family_project/processed/package_output/eversmoker/meta.log"
