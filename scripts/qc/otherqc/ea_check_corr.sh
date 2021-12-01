#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"

echo "Calculating rg between population and direct effects"
Rscript $scriptpath/estimate_marginal_correlations_meta.R \
--file "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/ea/CLEANED.out.gz" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/"