#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"


# python ${ssgac_path}/plotting/qqplot.py \
# --meta "/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/ea_dir.sumstats" \
# --title "EA Direct Effects" \
# --p "P" --z "Z" \
# --out "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/diagnostics/eb_dir_check.png"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/ea_pop.sumstats" \
# --title "EA Population Effects" \
# --p "P" --z "Z" \
# --out "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/diagnostics/eb_pop_check.png"



# python ${ssgac_path}/plotting/qqplot.py \
# --meta "/var/genetics/proj/within_family/within_family_project/processed/easyqc/estonian_biobank/CLEANED.eduyears.dir.sumstats.gz" \
# --title "EA Direct Effects" \
# --p "PVAL" --z "Z" \
# --lambda_xpos 4 --lambda_ypos 5 \
# --out "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/diagnostics/eb_dir_qc_check.png"

# python ${ssgac_path}/plotting/qqplot.py \
# --meta "/var/genetics/proj/within_family/within_family_project/processed/easyqc/estonian_biobank/CLEANED.eduyears.pop.sumstats.gz" \
# --title "EA Population Effects" \
# --p "PVAL" --z "Z" \
# --lambda_xpos 4 --lambda_ypos 5 \
# --out "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/diagnostics/eb_pop_qc_check.png"


python ${ssgac_path}/plotting/qqplot.py \
--meta "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/eb_samplingrg_outlierclean.sumstats" \
--title "EA Population Effects" \
--p "population_P" --z "population_Z" \
--lambda_xpos 4 --lambda_ypos 5 \
--out "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/qq_eb_pop_qc_rgfilter_check.png"

python ${ssgac_path}/plotting/qqplot.py \
--meta "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/eb_samplingrg_outlierclean.sumstats" \
--title "EA Direct Effects" \
--p "dir_P" --z "dir_Z" \
--lambda_xpos 4 --lambda_ypos 5 \
--out "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/qq_eb_dir_qc_rgfilter_check.png"