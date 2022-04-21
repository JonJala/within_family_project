#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/metal_output/metal_dir_bmi1.tbl" \
--title "BMI Direct Effects" \
--p "P-value" --z "Zscore" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/metal_output/plots/metal_dir_bmi_qq.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/metal_output/metal_pop_bmi1.tbl" \
--title "BMI Population Effects" \
--p "P-value" --z "Zscore" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/metal_output/plots/metal_pop_bmi_qq.png"


python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/metal_output/metal_dir_ea1.tbl" \
--title "EA Direct Effects" \
--p "P-value" --z "Zscore" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/metal_output/plots/metal_dir_ea_qq.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/metal_output/metal_pop_ea1.tbl" \
--title "EA Population Effects" \
--p "P-value" --z "Zscore" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/metal_output/plots/metal_pop_ea_qq.png"