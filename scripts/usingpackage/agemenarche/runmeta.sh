#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/agemenarche/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/agemenarche/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/agemenarche/meta.log

