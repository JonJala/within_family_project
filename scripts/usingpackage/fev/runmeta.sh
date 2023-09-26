#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/fev/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/fev/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/fev/meta.log

# without ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/fev/inputfiles_noukb.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/fev/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/fev/meta_noukb.log
