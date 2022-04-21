#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

# python ${ssgac_path}/plotting/manhattan.py \
# --meta_cleaned "${within_family_path}/processed/package_output/ea/ea_meta_analysis_amat.csv" \
# --title "EA \ Direct \ Effects" \
# --chr "CHR" --rsID "SNP" --bpos "BP" --p "pval_dir" --z "z_dir" \
# --pathout "${within_family_path}/processed/package_output/ea/manhattan_dir.png"

# python ${ssgac_path}/plotting/manhattan.py \
# --meta_cleaned "${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.csv" \
# --title "EA \ Direct \ Effects \ Incl \ EA4" \
# --chr "chromosome" --rsID "SNP" --bpos "pos" --p "dir_pval" --z "z_dir" \
# --pathout "${within_family_path}/processed/package_output/ea/manhattan_dir_ea4.png"

# python ${ssgac_path}/plotting/manhattan.py \
# --meta_cleaned "${within_family_path}/scratch/meta_analysis_sampleoverlap/with_ea4.csv" \
# --title "EA \ Direct \ Effects \ Incl \ EA4 \ (Sample \ overlap \ corrected)" \
# --chr "chromosome" --rsID "SNP" --bpos "pos" --p "dir_pval" --z "z_dir" \
# --pathout "${within_family_path}/processed/package_output/ea/manhattan_dir_ea4_sampleoverlap.png"


python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "${within_family_path}/processed/package_output/ea/ea_meta_analysis_newqc.csv" \
--title "EA \ Direct \ Effects" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "dir_pval" --z "dir_z" \
--pathout "${within_family_path}/processed/package_output/ea/manhattan_dir.png"

python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "${within_family_path}/processed/package_output/ea/ea_meta_analysis_newqc.csv" \
--title "EA \ Direct \ Effects" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "population_pval" --z "population_z" \
--pathout "${within_family_path}/processed/package_output/ea/manhattan_pop.png"
