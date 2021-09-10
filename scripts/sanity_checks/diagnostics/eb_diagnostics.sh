#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"
sniparpath="/homes/nber/harij/gitrepos/SNIPar"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr"

python $scriptpath/diagnostics.py \
"/var/genetics/proj/within_family/within_family_project/scripts/sanity_checks/diagnostics/eb_diagnostics.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/diagnostics/"