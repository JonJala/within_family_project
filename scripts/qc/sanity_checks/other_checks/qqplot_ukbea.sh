#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"


python ${ssgac_path}/plotting/qqplot.py \
--meta "/var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/21/ea_maternal.sumstats" \
--title "EA Maternal Effects" \
--p "P" --z "Z" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/ukb/ea_maternal.png"
