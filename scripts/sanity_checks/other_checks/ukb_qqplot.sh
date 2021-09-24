#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

python ${ssgac_path}/plotting/qqplot.py \
--meta "/var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/21/ea_pop.sumstats" \
--title "EA Population Effects" \
--p "P" --z "Z" \
--lambda_xpos 2 --lambda_ypos 5 \
--out "${within_family_path}/processed/sanity_checks/qq_pop.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "/var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/21/ea_dir.sumstats" \
--title "EA Direct Effects" \
--p "P" --z "Z" \
--lambda_xpos 2 --lambda_ypos 5 \
--out "${within_family_path}/processed/sanity_checks/qq_dir.png"