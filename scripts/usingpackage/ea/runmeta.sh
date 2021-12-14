#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# Base
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/ea/inputfiles.json" \
--outestimates "direct_population" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis"

# # with ea4
# python $scriptpath/run_metaanalysis.py \
# "/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/ea/inputfiles_withea4.json" \
# --outestimates "direct_population" \
# --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_ea4"

