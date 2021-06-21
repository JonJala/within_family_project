#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"
sniparpath="/homes/nber/harij/gitrepos/SNIPar"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr"

# python $scriptpath/diagnostics.py \
# "/var/genetics/proj/within_family/within_family_project/scripts/sanity_checks/diagnostics/moba_diagnostics.json" \
# --outprefix "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/diagnostics/moba"

# for pheno in bmi depanx fert ht inc
# do
#     echo $pheno
#     python $sniparpath/ldsc_reg/run_estimates.py \
#     "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/sumstats/${pheno}_chr*.sumstats.hdf5" \
#     -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
#     -bim_chromosome 0 -bim_bp 2 -bim_rsid 1 -bim_a1 3 -bim_a2 4 \
#     -e "direct_plus_population" \
#     -l "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/diagnostics/${pheno}_snipar.log"


# done

