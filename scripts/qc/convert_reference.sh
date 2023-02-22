#!/usr/bin/bash

# ----------------------------------------------- #
# File is meant to convert all reference panels
# to ldsc ready files
# ----------------------------------------------- #

within_family_path="/var/genetics/proj/within_family/within_family_project"
ldscpath="/disk/genetics/tools/ldsc/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# # testing out ldsc on reference files
# ${ldscpath}/munge_sumstats.py  \
# --sumstats  /var/genetics/data/published/yengo_2018_bmi/raw/sumstats/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.txt   \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED \
# --a1 Tested_Allele --a2 Other_Allele \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.txt  \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe \
# --N 1100000 \
# --chunksize 50000


${ldscpath}/munge_sumstats.py  \
--sumstats /var/genetics/data/published/howard_2019_mdd/raw/sumstats/PGC_UKB_depression_genome-wide.txt \
--merge-alleles ${merge_alleles} \
--out ${within_family_path}/processed/reference_samples/mdd_ref/PGC_UKB_depression_genome-wide \
--N 807553 --signed-sumstat LogOR,0 \
--chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/liu_2019_smoking/raw/sumstats/smokinginit.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/smoking_ref/Smokinginit \
# --chunksize 50000 \
# --a1 REF --a2 ALT

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/liu_2019_smoking/raw/sumstats/CigarettesPerDay.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/smoking_ref/cpd \
# --chunksize 50000 \
# --a1 REF --a2 ALT


# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/yengo_2018_height/raw/sumstats/Meta-analysis_Wood_et_al+UKBiobank_2018.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018 \
# --N-col EFFECTIVE_N --a1 Tested_Allele --a2 Other_Allele --frq Freq_Tested_Allele_in_HRS \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/okbay_2016_ds/raw/sumstats/DS_Full.txt \
# --merge-alleles ${merge_alleles} \
# --N 161460 \
# --out ${within_family_path}/processed/reference_samples/dep_ref/DS_Full \
# --chunksize 50000

# Hourly Income
# ${ldscpath}/munge_sumstats.py  \
# --sumstats ${within_family_path}/processed/reference_samples/inc_ref/GWAS_hourly_wage_UKB.txt \
# --merge-alleles ${merge_alleles} \
# --N 35000 \
# --out ${within_family_path}/processed/reference_samples/inc_ref/hourly_wage \
# --chunksize 50000

# # HH Income
# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/hill_2019_income/raw/sumstats/Household_Income_UKBiobank.txt.gz \
# --merge-alleles ${merge_alleles} \
# --N 286301 --a1 Effect_Allele --a2 Non_effect_Allele \
# --out ${within_family_path}/processed/reference_samples/inc_ref/hh_wage \
# --chunksize 50000

# # Fertility / NEB

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/barban_2016_repro/raw/sumstats/NumberChildrenEverBorn_Male.txt \
# --merge-alleles ${merge_alleles} \
# --N 343072 --frq Freq_HapMap \
# --out ${within_family_path}/processed/reference_samples/neb_ref/nchildren_male \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/barban_2016_repro/raw/sumstats/NumberChildrenEverBorn_Pooled.txt \
# --merge-alleles ${merge_alleles} \
# --N 343072 --frq Freq_HapMap \
# --out ${within_family_path}/processed/reference_samples/neb_ref/nchildren_pooled \
# --chunksize 50000

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/han_2020_asthma/raw/sumstats/HanY_prePMID_asthma_Meta-analysis_UKBB_TAGC.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/asthma_ref/asthma_ref \
# --chunksize 50000 \
# --a1 EA --a2 NEA

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/paternoster_2015_eczema/raw/sumstats/EAGLE_AD_no23andme_results_29072015.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/eczema_ref/eczema_ref \
# --chunksize 50000 \
# --a1 referece_allele --a2 other_allele --frq eaf --N-col AllEthnicities_N --p p.value

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/barban_2016_repro/raw/sumstats/AgeFirstBirth_Pooled.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/aafb_ref/aafb_ref \
# --chunksize 50000 \
# --frq Freq_HapMap --N 251151 --p Pvalue

# ${ldscpath}/munge_sumstats.py  \
# --sumstats/var/genetics/data/published/liu_2019_dpw/raw/sumstats/DrinksPerWeek.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/drinksperweek_ref/dpw_ref \
# --chunksize 50000 \
# --a1 REF --a2 ALT

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/nagel_2018b_neuroticism/raw/sumstats/sumstats_neuroticism_ctg_format.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/neuroticism_ref/neuroticism_ref \
# --chunksize 50000 \
# --frq EAF_UKB --snp RSID --ignore SNP

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/ferreira_2017_hayfever/raw/sumstats/hayfever_ref_rsids.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/hayfever_ref/hayfever_ref \
# --frq 1000G_ALLELE_FREQ --snp rsmid

# ${ldscpath}/munge_sumstats.py  \
# --sumstats  /var/genetics/data/published/loh_2018_bp/raw/sumstats/GCST90029011_buildGRCh37_bps.tsv \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/bps_ref/bps_ref \
# --snp variant_id --N-col n --p p_value --a1 effect_allele --a2 other_allele

# ${ldscpath}/munge_sumstats.py  \
# --sumstats  /var/genetics/data/published/loh_2018_bp/raw/sumstats/GCST90029010_buildGRCh37_bpd.tsv \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/bpd_ref/bpd_ref \
# --snp variant_id --N-col n --p p_value --a1 effect_allele --a2 other_allele

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

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/teslovich_2010_bloodlipids/raw/sumstats/HDL_with_Effect.tbl \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/hdl_ref/hdl_ref \
# --N 100000 --signed-sumstat GC.Zscore,0 --snp MarkerName

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/teslovich_2010_bloodlipids/raw/sumstats/LDL_with_Effect.tbl \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/ldl_ref/ldl_ref \
# --N 100000 --signed-sumstat GC.Zscore,0 --snp MarkerName

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/teslovich_2010_bloodlipids/raw/sumstats/TG_with_Effect.tbl \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/tg_ref/tg_ref \
# --N 100000 --signed-sumstat GC.Zscore,0 --snp MarkerName

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/teslovich_2010_bloodlipids/raw/sumstats/TC_with_Effect.tbl \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/cholestrol_ref/cholestrol_ref \
# --N 100000 --signed-sumstat GC.Zscore,0 --snp MarkerName

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/backman_2021_cannabis/raw/sumstats/GCST90078474_buildGRCh38_rsmid.tsv.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/cannabis_ref/cannabis_ref \
# --N 454787 --signed-sumstat odds_ratio,1 --snp rsmid --a1 effect_allele --a2 other_allele

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/loh_2017_agemenarche/raw/sumstats/GCST90029036_buildGRCh37.tsv \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/age_menarche_ref/age_menarche_ref \
# --N 279470 --snp variant_id --a1 effect_allele --a2 other_allele

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/shrine_2019_fev1/raw/sumstats/Shrine_30804560_FEV1_meta-analysis.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/fev1_ref/fev1_ref \
# --N-col TotalN --snp "#SNP" --a1 Coded --a2 Non_coded

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/harris_2017_srh/raw/sumstats/Harris2016_UKB_self_rated_health_summary_results_10112016.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/health_ref/health_ref \
# --N 111749

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/backman_2021_rhinitis/raw/sumstats/GCST90080105_buildGRCh38_rsids.tsv.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/rhinitis_ref/rhinitis_ref \
# --N 454787 --snp rsmid --signed-sumstats odds_ratio,1

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/demontis_2018_adhd/raw/sumstats/adhd.meta \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/adhd_ref/adhd_ref \
# --N 20183 --signed-sumstats OR,1 --frq FRQ_A_19099

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/proj/within_family/within_family_project/processed/reference_samples/migarine_ref/migraine_ihgc2021_gws_gwama_0.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/migarine_ref/migraine_ref \
# --N-col Neff --signed-sumstat z,1 --snp rs_number --a1 reference_allele --a2 other_allele --p p.value

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/berg_2015_extraversion/raw/sumstats/GPC-2.EXTRAVERSION_formatted.full.txt \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/extraversion_ref/extraversion_ref \
# --N 63030 --signed-sumstat Z,0 --snp RSNUMBER

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/jones_2019_morningperson/raw/sumstats/chronotype_raw_BOLT.output_HRC.only_plus.metrics_maf0.001_hwep1em12_info0.3.txt.gz \
# --merge-alleles ${merge_alleles} \
# --out ${within_family_path}/processed/reference_samples/morningpersion_ref/morningperson_ref \
# --N 697828 --p P_BOLT_LMM --a1 ALLELE1 --a2 ALLELE0

# ${ldscpath}/munge_sumstats.py  \
# --sumstats /var/genetics/data/published/jiang_2021_nearsight/raw/GCST90044218_buildGRCh37.tsv.gz \
# --merge-alleles ${merge_alleles} \
# --snp variant_id --a1 effect_allele --a2 other_allele --N-col N --frq effect_allele_frequency \
# --out ${within_family_path}/processed/reference_samples/nearsight/nearsight_ref \
# --N 697828