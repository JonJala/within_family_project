#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# with ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/nonhdl/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/nonhdl/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/nonhdl/meta.log

# without ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/nonhdl/inputfiles_noukb.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/nonhdl/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/nonhdl/meta_noukb.log
