#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
ldscpath="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# testing out ldsc on reference files
# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.txt   \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED \
# --a1 Tested_Allele --a2 Other_Allele \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/ea_ref/GWAS_EA_excl23andMe.txt  \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/ea_ref/GWAS_EA_excl23andMe \
# --N 1100000 \
# --chunksize 50000


# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/mdd_ref/PGC_UKB_depression_genome-wide.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/mdd_ref/PGC_UKB_depression_genome-wide \
# --N 807553 --signed-sumstat LogOR,0 \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/smoking_ref/Smokinginit.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/smoking_ref/Smokinginit \
# --N-col EFFECTIVE_N --ignore N --a1 REF --a2 ALT \
# --chunksize 50000


# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018 \
# --N-col EFFECTIVE_N --a1 Tested_Allele --a2 Other_Allele --frq Freq_Tested_Allele_in_HRS \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/dep_ref/DS_Full.txt \
# --merge-alleles ${merge_alleles} \
# --N 161460 \
# --out ${within_family_path}/processed/dep_ref/DS_Full \
# --chunksize 50000

# Hourly Income
# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/inc_ref/GWAS_hourly_wage_UKB.txt \
# --merge-alleles ${merge_alleles} \
# --N 35000 \
# --out ${within_family_path}/processed/inc_ref/hourly_wage \
# --chunksize 50000

# HH Income
# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/inc_ref/Household_Income_UKBiobank.txt.gz \
# --merge-alleles ${merge_alleles} \
# --N 286301 --a1 Effect_Allele --a2 Non_effect_Allele \
# --out ${within_family_path}/processed/inc_ref/hh_wage \
# --chunksize 50000
