#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/package_output/height_meta.csv" \
--title "Height Direct Effects" \
--p "pval_1" --z "z_1" \
--lambda_xpos 2 --lambda_ypos 2 \
--out "${within_family_path}/processed/package_output/height_qq_dir.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/package_output/height_meta.csv" \
--title "Height Population Effects" \
--p "pval_2" --z "z_2" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/processed/package_output/height_qq_pop.png"