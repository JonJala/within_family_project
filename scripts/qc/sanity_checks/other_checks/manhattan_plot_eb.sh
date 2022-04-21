#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"

# python ${ssgac_path}/plotting/manhattan.py \
# --meta_cleaned "/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/ea_dir.sumstats" \
# --title "EA \ Direct \ Effects" \
# --chr "chr" --rsID "SNP" --bpos "pos" --p "P" --z "Z" \
# --pathout "${within_family_path}/processed/sanity_checks/eb/manhattan_dir.png"


# python ${ssgac_path}/plotting/manhattan.py \
# --meta_cleaned "/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/ea_pop.sumstats" \
# --title "EA \ Population \ Effects" \
# --chr "chr" --rsID "SNP" --bpos "pos" --p "P" --z "Z" \
# --pathout "${within_family_path}/processed/sanity_checks/eb/manhattan_pop.png"


# python ${ssgac_path}/plotting/manhattan.py \
# --meta_cleaned "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/CLEANED.eduyears.dir.sumstats.gz" \
# --title "EA \ Direct \ Effects" \
# --chr "CHR" --rsID "SNP" --bpos "POS" --p "PVAL" --z "Z" \
# --pathout "${within_family_path}/processed/sanity_checks/eb/manhattan_qced_dir.png"


# python ${ssgac_path}/plotting/manhattan.py \
# --meta_cleaned "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/CLEANED.eduyears.pop.sumstats.gz" \
# --title "EA \ Population \ Effects" \
# --chr "CHR" --rsID "SNP" --bpos "POS" --p "PVAL" --z "Z" \
# --pathout "${within_family_path}/processed/sanity_checks/eb/manhattan_qceD_pop.png"

python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/eb_samplingrg_outlierclean.sumstats" \
--title "EA \ Direct \ Effects" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "dir_P" --z "dir_Z" \
--pathout "${within_family_path}/processed/sanity_checks/eb/manhattan_qced_rg_dir.png"

python ${ssgac_path}/plotting/manhattan.py \
--meta_cleaned "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/eb_samplingrg_outlierclean.sumstats" \
--title "EA \ Population \ Effects" \
--chr "CHR" --rsID "SNP" --bpos "BP" --p "population_P" --z "population_Z" \
--pathout "${within_family_path}/processed/sanity_checks/eb/manhattan_qced_rg_pop.png"
