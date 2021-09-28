#!/usr/bin/bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"


python ${ssgac_path}/plotting/qqplot.py \
--meta "/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/ea_dir.sumstats" \
--title "EA Direct Effects" \
--p "P" --z "Z" \
--out "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/diagnostics/eb_dir_check.png"