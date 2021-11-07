#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/package_output/bmi/bmi_meta_newqc.csv" \
--title "BMI Direct Effects" \
--p "dir_pval" --z "dir_z" \
--lambda_xpos 2 --lambda_ypos 2 \
--out "${within_family_path}/processed/package_output/bmi/qq_dir.png"


python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/package_output/bmi/bmi_meta_newqc.csv" \
--title "BMI Population Effects" \
--p "population_pval" --z "population_z" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/package_output/bmi/qq_pop.png"