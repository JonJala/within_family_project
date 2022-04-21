#!/usr/bin/bash

# Running snipar for outputted meta
# analyses to see if things look
# alright

sniparpath="/homes/nber/harij/gitrepos/SNIPar"
within_family_path="/homes/nber/harij/within_family"
ldscpath="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


python ${sniparpath}/ldsc_reg/run_estimates.py \
"/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis_population.sumstats.hdf5" \
-bim_bp 2 -bim_a1 3 -bim_a2 4 \
-ldsc "${eur_w_ld_chr}/*[0-9].l2.ldscore.gz" \
-l "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/dir_pop_excl_gs_sldsc.log" \
-e "full" \
-maf 1 
