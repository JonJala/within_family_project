#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
ldsc_path="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/ea/Eduhunt_results_ldsc_pop.sumstats.gz,${within_family_path}/processed/ea_ref/GWAS_EA_excl23andMe.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/hunt/ea
# # 1.0748 (0.1255)


# # Age first birth
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/AgeFirstBirth/AgeFirstBirth_ldsc_pop.sumstats.gz,${within_family_path}/processed/aafb_ref/aafb_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/hunt/aafb
# 1.0605 (0.1969)

# children n
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/ChildrenN/ChildrenN_ldsc_pop.sumstats.gz,${within_family_path}/processed/neb_ref/nchildren_pooled.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/hunt/nchildren
#  0.5584 too low

# Drinks per week
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/DrinksPerWeek/DrinksPerWeek_ldsc_pop.sumstats.gz,${within_family_path}/processed/drinksperweek_ref/dpw_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/hunt/drinksperweek
# -0.9059 (0.187)

# Height
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/height/height_ldsc_pop.sumstats.gz,${within_family_path}/processed/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/hunt/height
# 0.9522 (0.0208)

# Neuroticism
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/neuroticism/neuroticism_ldsc_pop.sumstats.gz,${within_family_path}/processed/neuroticism_ref/neuroticism_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/hunt/neuroticism
# 0.7476 (0.0773)