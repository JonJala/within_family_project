#!/usr/bin/bash
sniparpath="/homes/nber/harij/gitrepos/SNIPar"
within_family_path="/var/genetics/proj/within_family/within_family_project"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"

python "${sniparpath}/ldsc_reg/run_estimates.py" \
        "${within_family_path}/notebooks/creating_package/bmi/meta_analysis_pop.sumstats.hdf5" \
        -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
        -e "full" \
        -bim_bp 2 -bim_a1 3 -bim_a2 4 \
        -maf 1 \
        -l "${within_family_path}/notebooks/creating_package/bmi/snipar_pop.log"


python "${sniparpath}/ldsc_reg/run_estimates.py" \
        "${within_family_path}/notebooks/creating_package/bmi/meta_analysis_avgpar.sumstats.hdf5" \
        -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
        -e "full" \
        -bim_bp 2 -bim_a1 3 -bim_a2 4 \
        -maf 1 \
        -l "${within_family_path}/notebooks/creating_package/bmi/snipar_avgpar.log"


python "${sniparpath}/ldsc_reg/run_estimates.py" \
        "${within_family_path}/notebooks/creating_package/ea/meta_analysis_pop.sumstats.hdf5" \
        -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
        -e "full" \
        -bim_bp 2 -bim_a1 3 -bim_a2 4 \
        -maf 1 \
        -l "${within_family_path}/notebooks/creating_package/ea/snipar_pop.log"


python "${sniparpath}/ldsc_reg/run_estimates.py" \
        "${within_family_path}/notebooks/creating_package/ea/meta_analysis_avgpar.sumstats.hdf5" \
        -ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
        -e "full" \
        -bim_bp 2 -bim_a1 3 -bim_a2 4 \
        -maf 1 \
        -l "${within_family_path}/notebooks/creating_package/ea/snipar_avgpar.log"

