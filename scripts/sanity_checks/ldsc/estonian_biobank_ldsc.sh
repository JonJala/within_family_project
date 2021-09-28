#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
ldscpath="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"


# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/bmi.sumstats,${within_family_path}/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out /var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/bmi_ldsc
# # # Genetic Correlation: 0.8344 (0.0381)


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
# --rg /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_dir.sumstats.sumstats.gz,${within_family_path}/processed/mdd_ref/PGC_UKB_depression_genome-wide.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/mdd_ref/mdd_dir

# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_pop.sumstats.sumstats.gz,${within_family_path}/processed/mdd_ref/PGC_UKB_depression_genome-wide.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/mdd_ref/mdd_pop

# python ${ldsc_path}/ldsc.py \
# --rg /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_dir.sumstats.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mdd_pop.sumstats.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/mdd_ref/mdd_dir_pop

# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/smoking_ref/Smokinginit.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/smoke_pop.sumstats \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/eb/ldsc_smokever
# -0.8936 (0.0351) - reference panel might have flipped effect


# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/asthma_ref/asthma_ref.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/asthma_pop.sumstats \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/eb/ldsc_asthma
# # 1.1249


# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/dep_ref/DS_Full.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/depression_pop.sumstats \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/eb/depression
# # 1.1202

# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/aafb_ref/aafb_ref.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/aafb_pop.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/eb/aafb
# 1.1721 (0.2297)


# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/eczema_ref/eczema_ref.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/eczema_pop.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/sanity_checks/eb/ldsc_eczema
# 1.0224 (0.2611)

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz,/var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/ea_pop.sumstats \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/sanity_checks/eb/ea
# 0.9514 (0.0493)