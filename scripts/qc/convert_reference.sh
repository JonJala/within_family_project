#!/usr/bin/bash

# ----------------------------------------------- #
# File is meant to convert all reference panels
# to ldsc ready files
# ----------------------------------------------- #

within_family_path="/var/genetics/proj/within_family/within_family_project"
ldscpath="/homes/nber/harij/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# testing out ldsc on reference files
# ${ldscpath}/munge_sumstats.py  \
# --sumstats  /var/genetics/data/published/yengo_2018_bmi/raw/sumstats/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.txt   \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED \
# --a1 Tested_Allele --a2 Other_Allele \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/ea_ref/GWAS_EA_excl23andMe.txt  \
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
# --sumstats ${within_family_path}/processed/smoking_ref/smokinginit.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/smoking_ref/Smokinginit \
# --chunksize 50000 \
# --a1 REF --a2 ALT


# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/yengo_2018_height/raw/sumstats/Meta-analysis_Wood_et_al+UKBiobank_2018.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018 \
# --N-col EFFECTIVE_N --a1 Tested_Allele --a2 Other_Allele --frq Freq_Tested_Allele_in_HRS \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/okbay_2016_ds/raw/sumstats/DS_Full.txt \
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

# # HH Income
# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/inc_ref/Household_Income_UKBiobank.txt.gz \
# --merge-alleles ${merge_alleles} \
# --N 286301 --a1 Effect_Allele --a2 Non_effect_Allele \
# --out ${within_family_path}/processed/inc_ref/hh_wage \
# --chunksize 50000

# # Fertility / NEB

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/barban_2016_repro/raw/sumstats/NumberChildrenEverBorn_Male.txt \
# --merge-alleles ${merge_alleles} \
# --N 343072 --frq Freq_HapMap \
# --out ${within_family_path}/processed/neb_ref/nchildren_male \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/barban_2016_repro/raw/sumstats/NumberChildrenEverBorn_Pooled.txt \
# --merge-alleles ${merge_alleles} \
# --N 343072 --frq Freq_HapMap \
# --out ${within_family_path}/processed/neb_ref/nchildren_pooled \
# --chunksize 50000



# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/han_2020_asthma/raw/sumstats/HanY_prePMID_asthma_Meta-analysis_UKBB_TAGC.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/asthma_ref/asthma_ref \
# --chunksize 50000 \
# --a1 EA --a2 NEA

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/paternoster_2015_eczema/raw/sumstats/EAGLE_AD_no23andme_results_29072015.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/eczema_ref/eczema_ref \
# --chunksize 50000 \
# --a1 referece_allele --a2 other_allele --frq eaf --N-col AllEthnicities_N --p p.value

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/barban_2016_repro/raw/sumstats/AgeFirstBirth_Pooled.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/aafb_ref/aafb_ref \
# --chunksize 50000 \
# --frq Freq_HapMap --N 251151 --p Pvalue


# ${ldscpath}/munge_sumstats.py  \
# --sumstats/var/genetics/data/published/liu_2019_dpw/raw/sumstats/DrinksPerWeek.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/drinksperweek_ref/dpw_ref \
# --chunksize 50000 \
# --a1 REF --a2 ALT



${ldscpath}/munge_sumstats.py  \
--sumstats /var/genetics/data/published/nagel_2018b_neuroticism/raw/sumstats/sumstats_neuroticism_ctg_format.txt.gz \
--merge-alleles ${merge_alleles} \
--out ${within_family_path}/processed/neuroticism_ref/neuroticism_ref \
--chunksize 50000 \
--frq EAF_UKB --snp RSID --ignore SNP



# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/reference_samples/hayfever_ref/hayfever_ref.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/hayfever_ref/hayfever_ref \
# --frq 1000G_ALLELE_FREQ



# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/ehret_2016_bps/raw/sumstats/Ehret_2016_summstats_formatted.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/bps_ref/bps_ref \
# --snp rsid --N-col TotalSampleSize_SBP --signed-sumstat ZSCORE,0 --p P_SBP

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/okbay_2016_swb/raw/sumstats/SWB_Full.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/swb_ref/swb_ref \
# --snp MarkerName --N 298420 

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/sniekers_2017_intelligence/raw/sumstats/sumstats.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/intelligence_ref/intelligence_ref \
# --N 78308 --signed-sumstat Zscore,0 --a1 ref --a2 alt