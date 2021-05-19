#!/usr/bin/bash
sniparpath="/homes/nber/harij/gitrepos/SNIPar"
within_family_path="/var/genetics/proj/within_family/within_family_project"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"

python "${sniparpath}/ldsc_reg/run_estimates.py" \
        "${within_family_path}/processed/package_output/ea/ea_meta_analysis_avgparental.sumstats.hdf5" \
        -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
        -e "full" \
        -bim_bp 2 -bim_a1 3 -bim_a2 4 \
        -maf 1 \
        -l "${within_family_path}/processed/package_output/ea/snipar_avgparental.log"

python "${sniparpath}/ldsc_reg/run_estimates.py" \
        "${within_family_path}/processed/package_output/ea/ea_meta_analysis_population.sumstats.hdf5" \
        -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
        -e "full" \
        -bim_bp 2 -bim_a1 3 -bim_a2 4 \
        -maf 1 \
        -l "${within_family_path}/processed/package_output/ea/snipar_population.log"


