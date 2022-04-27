#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"


# python $scriptpath/run_metaanalysis.py \
# "/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/cognition/inputfiles.json" \
# --outestimates "avgparental_to_population" \
# --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/cognition/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/cognition/meta.log


python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/cognition/inputfiles_noukb.json" \
--outestimates "avgparental_to_population" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/cognition/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/cognition/meta_noukb.log