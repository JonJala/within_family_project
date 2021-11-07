#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/package_output/ea/eb_nocontrol/ea_meta_analysis_newqc_ebnocontrol.csv" \
--title "EA Direct Effects" \
--p "dir_pval" --z "dir_z" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/package_output/ea/eb_nocontrol/qq_dir_new.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/package_output/ea/eb_nocontrol/ea_meta_analysis_newqc_ebnocontrol.csv" \
--title "EA Population Effects" \
--p "population_pval" --z "population_z" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/package_output/ea/eb_nocontrol/qq_pop_new.png"