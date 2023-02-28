#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# with ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/aafb/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/aafb/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/aafb/meta.log

# without ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/aafb/inputfiles_noukb.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/aafb/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/aafb/meta_noukb.log
