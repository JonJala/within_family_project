#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"


python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/bmi/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/meta.log

# without hunt
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/bmi/inputfiles_nohunt.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/meta_nohunt" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/meta_nohunt.log
