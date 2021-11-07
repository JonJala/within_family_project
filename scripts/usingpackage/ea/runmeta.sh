#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# Base
# python $scriptpath/run_metaanalysis.py \
# "/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/ea/inputfiles.json" \
# --outestimates "direct_population" \
# --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_newqc"


python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/ea/inputfiles_ebnocontrol.json" \
--outestimates "direct_population" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/eb_nocontrol/ea_meta_analysis_newqc_ebnocontrol"


# With EA4
# python $scriptpath/run_metaanalysis.py \
# "/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/ea/inputfiles_ea4_nogs.json" \
# --outestimates "direct_population" \
# --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_ea4_onpos"