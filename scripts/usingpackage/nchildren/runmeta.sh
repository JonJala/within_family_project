#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# with ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/nchildren/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/nchildren/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/nchildren/meta.log

# without ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/nchildren/inputfiles_noukb.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/nchildren/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/nchildren/meta_noukb.log
