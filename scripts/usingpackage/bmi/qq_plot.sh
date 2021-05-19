#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/notebooks/creating_package/bmi/meta_analysis_package.csv" \
--title "BMI Direct Effects" \
--p "pval_1" --z "z_1" \
--lambda_xpos 2 --lambda_ypos 2 \
--out "${within_family_path}/notebooks/creating_package/bmi/qq_dir.png"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "${within_family_path}/notebooks/creating_package/bmi/meta_analysis_package.csv" \
# --title "BMI Average Parental Effects" \
# --p "pval_indir" --z "z_indir" \
# --lambda_xpos 3 --lambda_ypos 5 \
# --out "${within_family_path}/notebooks/creating_package/bmi/qq_avgparental.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/notebooks/creating_package/bmi/meta_analysis_package.csv" \
--title "BMI Population Effects" \
--p "pval_2" --z "z_2" \
--lambda_xpos 3 --lambda_ypos 5 \
--out "${within_family_path}/notebooks/creating_package/bmi/qq_pop.png"