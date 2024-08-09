#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

## without ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/height/inputfiles_noukb.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta_noukb.log

## with ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/height/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta.log

## without hunt
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/height/inputfiles_nohunt.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta_nohunt" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/height/meta_nohunt.log
