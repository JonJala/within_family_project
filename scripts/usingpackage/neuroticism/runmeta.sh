#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"


python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/neuroticism/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/neuroticism/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/neuroticism/meta.log
