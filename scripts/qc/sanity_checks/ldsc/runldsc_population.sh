#!/usr/bin/bash

# Runs LDSC for all converted cohort files
# to estimate correlation of population effects
# between cohort and publicly avaiable GWAS
# results

within_family_path="/var/genetics/proj/within_family/within_family_project"
ldsc_path="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


# == STR == #
# python ${ldsc_path}/munge_sumstats.py \
# --sumstats /var/genetics/data/str/public/latest/raw/sumstats/fgwas/bmi/bmi_ldsc.sumstats \
# --signed-sumstats Z,0 \
# --merge-alleles ${merge_alleles} \
# --out /var/genetics/data/str/public/latest/raw/sumstats/fgwas/bmi/bmi_ldsc


# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/str/public/latest/raw/sumstats/fgwas/bmi/bmi_ldsc.sumstats,${within_family_path}/bmi_ref/bmi_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/data/str/public/latest/raw/sumstats/fgwas/eduYears/eduYears_ldsc
# # rg cant be estimated cause h2 < 0. Doesnt work even after munge stats
# # This is odd


# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/str/public/latest/raw/sumstats/fgwas/eduYears/eduYears_ldsc.sumstats,${within_family_path}/ea_ref/ea_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/data/str/public/latest/raw/sumstats/fgwas/eduYears/eduYears_ldsc
# # # ldsc rg = 1.0072 (0.6595)


# # == Generation Scotland == #
# # 10 = EA
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/10/ldsc.sumstats,${within_family_path}/ea_ref/ea_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/10/EA_ldsc
# # # rg = 0.8124 (0.1005)

# # # 6 = BMI
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/6/ldsc.sumstats,${within_family_path}/bmi_ref/bmi_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/6/bmi_ldsc
# # rg =  0.9297 (0.0694)

# # == Finnish Twins == #
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/EA.sumstats,${within_family_path}/ea_ref/ea_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/ea_ldsc
# # # Genetic Correlation: nan (nan) (h2  out of bounds) 

# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/bmi.sumstats,${within_family_path}/bmi_ref/bmi_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/bmi_ldsc
# # Genetic Correlation: 0.7958 (0.1384)

# # == Estonian Biobank == #
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/bmi.sumstats,${within_family_path}/bmi_ref/bmi_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/bmi_ldsc
# # # Genetic Correlation: 0.8344 (0.0381)


# # == UKB == #
# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/13/bmi_pop.sumstats,${within_family_path}/bmi_ref/bmi_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/proj/within_family/within_family_project/processed/sanity_checks/ukb/bmi_ldsc
# # 0.9011 (0.023)

# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/21/ea_pop.sumstats,/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/ea_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/proj/within_family/within_family_project/processed/sanity_checks/ukb/ea_ldsc
# # 1.0256 (0.0335)



# Depression

# munge the PGI mdd
# python ${ldsc_path}/munge_sumstats.py \
# --sumstats /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_dir.sumstats \
# --signed-sumstats Z,0 --ignore MAF \
# --merge-alleles ${merge_alleles} \
# --out /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_dir.sumstats

# python ${ldsc_path}/munge_sumstats.py \
# --sumstats /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_pop.sumstats \
# --signed-sumstats Z,0 --ignore MAF \
# --merge-alleles ${merge_alleles} \
# --out /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_pop.sumstats


# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_dir.sumstats.sumstats.gz,${within_family_path}/processed/depression_ref/depression_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/mdd_ref/mdd_dir

# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_pop.sumstats.sumstats.gz,${within_family_path}/processed/depression_ref/depression_ref.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/mdd_ref/mdd_pop

# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_dir.sumstats.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_pop.sumstats.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/mdd_ref/mdd_dir_pop
