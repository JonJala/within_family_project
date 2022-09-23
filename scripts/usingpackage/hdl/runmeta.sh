#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# with ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/hdl/inputfiles.json" \
--outestimates "avgparental_to_population" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/hdl/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/hdl/meta.log

# without ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/hdl/inputfiles_noukb.json" \
--outestimates "avgparental_to_population" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/hdl/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/hdl/meta_noukb.log