within_family_path="/var/genetics/proj/within_family/within_family_project"
ldsc_path="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# BMI
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/moba/public/latest/processed/sumstats/fgwas/bmi.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/moba/ldsc_bmi
# Genetic Correlation: 0.9838 (0.2953)


# height
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/moba/public/latest/processed/sumstats/fgwas/ht.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/moba/ldsc_ht
# Genetic Correlation: 0.8651 (0.1034)



