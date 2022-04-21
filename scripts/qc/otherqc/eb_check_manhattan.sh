#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

# python ${ssgac_path}/plotting/manhattan.py \
# --meta_cleaned "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/ea/CLEANED.out.gz" \
# --title "EA \ Direct \ Effects \ EB" \
# --chr "CHR" --rsID "SNP" --bpos "BP" --p "PVAL_direct" --z "z_direct" \
# --pathout "${within_family_path}/processed/qc/estonian_biobank/ea/manhattan_dir.png"


python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/ea/controls/CLEANED.out.gz" \
--title "EA \ Population \ Effects \ EB" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "PVAL_direct" --z "z_direct" \
--pathout "${within_family_path}/processed/qc/estonian_biobank/ea/controls/manhattan_dir.png"
