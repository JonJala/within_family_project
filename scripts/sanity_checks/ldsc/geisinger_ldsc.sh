within_family_path="/var/genetics/proj/within_family/within_family_project"
ldsc_path="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# Asthma
python ${ldsc_path}/ldsc.py \
--rg /var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/asthma.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/asthma_ref/asthma_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/geisinger/ldsc_asthma
#  1.1864 (0.443)

# BMI
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/bmi.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/geisinger/ldsc_bmi
# 0.9428 (0.0311)


# Height
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/height.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/geisinger/ldsc_height
# 0.9462 (0.0229)

# dperessive symptoms
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/depression.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/dep_ref/DS_Full.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/geisinger/ldsc_dep
# 0.7556 (0.1056)

# EA
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/edu_years.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/ea_ref/GWAS_EA_excl23andMe.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/geisinger/ldsc_ea
# 1.0861 (0.3232)

# SMoke ever
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/geisinger/public/latest/processed/sumstats/fgwas/smoke_ever.pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/smoking_ref/Smokinginit.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/geisinger/ldsc_smokever
# -0.9604 (0.0598) - i think reference sample might be flipped. same negative result for eb

