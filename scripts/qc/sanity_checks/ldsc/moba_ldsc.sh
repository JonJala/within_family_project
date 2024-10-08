within_family_path="/var/genetics/proj/within_family/within_family_project"
ldsc_path="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# BMI
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/moba/public/latest/processed/sumstats/fgwas/bmi.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/bmi_ref/bmi_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/moba/ldsc_bmi
# Genetic Correlation: 0.9838 (0.2953)


# height
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/moba/public/latest/processed/sumstats/fgwas/ht.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/height_ref/height_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/moba/ldsc_ht
# Genetic Correlation: 0.8651 (0.1034)

# Depressive symptoms
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/moba/public/latest/processed/sumstats/fgwas/depanx.pop.sumstats.gz,/var/genetics/proj/within_family/within_family_project/processed/depsymp_ref/depsymp_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/moba/ldsc_depanx
# Error, h2 of measure is <0 ?

# Income
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/moba/public/latest/processed/sumstats/fgwas/inc.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/hhincome_ref/hhincome_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/moba/ldsc_inc_hh
# Negative h2 again?

## Fertility
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/moba/public/latest/processed/sumstats/fgwas/fert.pop.sumstats.gz,/var/genetics/proj/within_family/within_family_project/processed/fert_ref/fert_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/moba/ldsc_fert
# unable to compute rg because of some jkse estimates being <0 for h2. Could be due to
# low power