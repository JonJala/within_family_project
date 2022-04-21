#!/usr/bin/env bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"
sniparpath="/homes/nber/harij/gitrepos/SNIPar"

# python $scriptpath/diagnostics.py \
#     "/var/genetics/proj/within_family/within_family_project/scripts/usingpackage/smoking/inputfiles.json" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/smoking/diagnostics"

python ${sniparpath}/ldsc_reg/run_estimates.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/smoke/SMOKE_chr*_results.sumstats.hdf5" \
    -bim_chromosome 0 -bim_bp 2 \
    -bim_rsid 1 -bim_a1 3 -bim_a2 4 \
    -ldsc "/disk/genetics4/ukb/alextisyoung/haplotypes/relatives/bedfiles/ldscores/*[0-9].l2.ldscore.gz" \
    -l "/var/genetics/proj/within_family/within_family_project/processed/package_output/smoking/snipar.log"

