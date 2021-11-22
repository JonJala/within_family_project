#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"


python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/package_output/ea/ea_meta_analysis.sumstats" \
--title "EA Direct Effects" \
--p "direct_pval" --z "direct_z" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/package_output/ea/qq_dir.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/package_output/ea/ea_meta_analysis.sumstats" \
--title "EA Population Effects" \
--p "population_pval" --z "population_z" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/package_output/ea/qq_pop.png"