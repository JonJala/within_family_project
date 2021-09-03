within_family_path="/var/genetics/proj/within_family/within_family_project"
ldsc_path="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# bmi
python ${ldsc_path}/ldsc.py \
--rg /disk/genetics/data/lifelines/public/latest/processed/sumstats/fgwas/fgwas_ll_bmi_population.sumstats.gz,/var/genetics/proj/within_family/within_family_project/processed/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/lifelines/ldsc_bmi
# 0.8593

python ${ldsc_path}/ldsc.py \
--rg /disk/genetics/data/lifelines/public/latest/processed/sumstats/fgwas/fgwas_ll_bmi18_population.sumstats.gz,/var/genetics/proj/within_family/within_family_project/processed/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/lifelines/ldsc_bmi18
# 0.8964

# height
python ${ldsc_path}/ldsc.py \
--rg /disk/genetics/data/lifelines/public/latest/processed/sumstats/fgwas/fgwas_ll_height_population.sumstats.gz,/var/genetics/proj/within_family/within_family_project/processed/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/lifelines/ldsc_bmi
# 0.9362 

python ${ldsc_path}/ldsc.py \
--rg /disk/genetics/data/lifelines/public/latest/processed/sumstats/fgwas/fgwas_ll_height18_population.sumstats.gz,/var/genetics/proj/within_family/within_family_project/processed/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/lifelines/ldsc_bmi18
# 1.0015