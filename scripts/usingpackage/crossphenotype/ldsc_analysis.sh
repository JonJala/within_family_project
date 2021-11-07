#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_dir.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_dir.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/package_output/crossphenotype/eadir_bmidir_ldsc.log
# # -0.1872 (0.0613)

# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_pop.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_pop.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/package_output/crossphenotype/eapop_bmipop_ldsc.log
# # -0.314 (0.025)

# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz,${within_family_path}/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/package_output/crossphenotype/earef_bmiref_ldsc.log
# # -0.2677 (0.0133)

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/height/height_meta_dir.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_dir.sumstats.gz  \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/crossphenotype/ht_ea_dir
# 0.1635 (0.0402)

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/height/height_meta_pop.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_pop.sumstats.gz  \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/crossphenotype/ht_ea_pop
# 0.2066 (0.0192)

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz,${within_family_path}/processed/reference_samples/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/crossphenotype/ht_ea_ref
# 0.138 (0.0116)