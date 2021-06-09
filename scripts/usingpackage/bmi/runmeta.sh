#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"


python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/bmi/inputfiles.json" \
--outestimates "avgparental_to_population" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/bmi_meta" \
--diag