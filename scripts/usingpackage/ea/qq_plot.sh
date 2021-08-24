#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "${within_family_path}/processed/package_output/ea/ea_meta_analysis_amat.csv" \
# --title "EA Direct Effects" \
# --p "pval_dir" --z "z_dir" \
# --lambda_xpos 2 --lambda_ypos 2 \
# --out "${within_family_path}/processed/package_output/ea/qq_dir.png"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "${within_family_path}/processed/package_output/ea/ea_meta_analysis_amat.csv" \
# --title "EA Average Parental Effects" \
# --p "pval_avgparental" --z "z_avgparental" \
# --lambda_xpos 3 --lambda_ypos 5 \
# --out "${within_family_path}/processed/package_output/ea/qq_avgparental.png"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "${within_family_path}/processed/package_output/ea/ea_meta_analysis_amat.csv" \
# --title "EA Population Effects" \
# --p "pval_population" --z "z_population" \
# --lambda_xpos 3 --lambda_ypos 5 \
# --out "${within_family_path}/processed/package_output/ea/qq_pop.png"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.csv" \
# --title "EA Direct Effects" \
# --p "pval_dir" --z "z_dir" \
# --lambda_xpos 2 --lambda_ypos 2 \
# --out "${within_family_path}/processed/package_output/ea/qq_dir_ea4.png"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.csv" \
# --title "EA Average Parental Effects" \
# --p "pval_avgparental" --z "z_avgparental" \
# --lambda_xpos 3 --lambda_ypos 5 \
# --out "${within_family_path}/processed/package_output/ea/qq_avgparental_ea4.png"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.csv" \
# --title "EA Population Effects" \
# --p "pval_population" --z "z_population" \
# --lambda_xpos 3 --lambda_ypos 5 \
# --out "${within_family_path}/processed/package_output/ea/qq_pop_ea4.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "${within_family_path}/processed/ea4/ea4_excl_ukb_str_gs_2020_08_21.txt" \
--title "EA4" \
--p "P" --z "Z" \
--out "${within_family_path}/processed/package_output/ea/ea4.png"
