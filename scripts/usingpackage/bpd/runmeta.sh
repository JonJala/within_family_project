#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# with ukb
python $scriptpath/run_metaanalysis.py \
"/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/bpd/inputfiles.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/bpd/meta" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/bpd/meta.log

# # without ukb
# python $scriptpath/run_metaanalysis.py \
# "/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/bpd/inputfiles_noukb.json" \
# --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/bpd/meta_noukb" | tee /var/genetics/proj/within_family/within_family_project/processed/package_output/bpd/meta_noukb.log
