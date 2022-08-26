#!/usr/bin/bash

# ldscpath="/var/genetics/pub/software/ldsc"
ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/var/genetics/proj/within_family/within_family_project/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

# echo "Munging!!"
source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/depression/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/depression/directmunged \
--N-col direct_N --p direct_pval --signed-sumstats direct_Z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/depression/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/depression/populationmunged \
--N-col population_N --p population_pval --signed-sumstats population_Z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/depression/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/depression/paternalmunged \
--N-col direct_N --p paternal_pval --signed-sumstats paternal_Z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/depression/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/depression/maternalmunged \
--N-col direct_N --p maternal_pval --signed-sumstats maternal_Z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/depression/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/depression/ntcmunged \
--N-col direct_N --p avg_NTC_pval --signed-sumstats avg_NTC_Z,0 \
--merge-alleles ${hm3snps}

echo "Calcualting RG of population effect with reference dpression sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/depression/populationmunged.sumstats.gz,${within_family_path}/processed/reference_samples/dep_ref/DS_Full.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/depression/population_reference_sample
# 1.0353 (0.0159)

echo "Calcualting RG of direct effect with reference depression sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/depression/directmunged.sumstats.gz,${within_family_path}/processed/reference_samples/dep_ref/DS_Full.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/depression/direct_reference_sample
# 1.0353 (0.0159)

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/depression/paternalmunged.sumstats.gz,${within_family_path}/processed/package_output/depression/maternalmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/depression/maternal_vs_paternal
# -0.0501 (0.3567)


${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/depression/ntcmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/depression/h2_ntc
# 0.0367 (0.0072)

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/depression/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/depression/direct_h2

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/depression/populationmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/depression/population_h2

# Changing env
source /var/genetics/proj/within_family/within_family_project/snipar/bin/activate
/var/genetics/proj/within_family/within_family_project/snipar/snipar/scripts/correlate.py /var/genetics/proj/within_family/within_family_project/processed/package_output/depression/meta.nfilter \
/var/genetics/proj/within_family/within_family_project/processed/package_output/depression/marginal \
--ldscores /disk/genetics/ukb/alextisyoung/hapmap3/ldscores/@