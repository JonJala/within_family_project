#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "${within_family_path}/processed/package_output/ea/ea_meta_analysis_amat.csv" \
--title "EA \ Direct \ Effects" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "pval_dir" --z "z_dir" \
--pathout "${within_family_path}/processed/package_output/ea/manhattan_dir.png"


python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.csv" \
--title "EA \ Direct \ Effects \ Incl \ EA4" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "pval_dir" --z "z_dir" \
--pathout "${within_family_path}/processed/package_output/ea/manhattan_dir_ea4.png"

