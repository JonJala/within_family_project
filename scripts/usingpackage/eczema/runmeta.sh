#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

## with UKB
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/eczema/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/eczema/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/eczema/meta.log

## without UKB
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/eczema/inputfiles_noukb.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/eczema/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/eczema/meta_noukb.log
