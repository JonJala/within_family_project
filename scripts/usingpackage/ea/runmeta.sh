#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# Base
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/ea/inputfiles_minimal.json" \
--outestimates "direct_population" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_amat"

# With EA4
# python $scriptpath/run_metaanalysis.py \
# "/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/ea/inputfiles_nogs.json" \
# --outestimates "avgparental_to_population" \
# --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis"