#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_dir.sumstats.gz,${within_family_path}/processed/package_output/bmi/meta_analysis_avgparental.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/crossphenotype/eadir_bmiavgparental_ldsc.log


${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_dir.sumstats.gz,${within_family_path}/processed/package_output/bmi/meta_analysis_dir.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/crossphenotype/eadir_bmidir_ldsc.log


${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_pop.sumstats.gz,${within_family_path}/processed/package_output/bmi/meta_analysis_pop.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/crossphenotype/eapop_bmipop_ldsc.log



${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_avgparental.sumstats.gz,${within_family_path}/processed/package_output/bmi/meta_analysis_dir.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/crossphenotype/eaavgparental_bmidir_ldsc.log