#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "${within_family_path}/processed/package_output/ea/eb_nocontrol/ea_meta_analysis_newqc_ebnocontrol.csv" \
--title "EA \ Direct \ Effects" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "dir_pval" --z "dir_z" \
--pathout "${within_family_path}/processed/package_output/ea/eb_nocontrol/manhattan_dir.png"

python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "${within_family_path}/processed/package_output/ea/ea_meta_analysis_newqc_ebnocontrol.csv" \
--title "EA \ Direct \ Effects" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "population_pval" --z "population_z" \
--pathout "${within_family_path}/processed/package_output/ea/eb_nocontrol/manhattan_pop.png"