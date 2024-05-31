#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/var/genetics/proj/within_family/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"

source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/ea/directmunged \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/ea/populationmunged \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/ea/ntcmunged \
--N-col direct_N --p avg_NTC_pval --signed-sumstats avg_NTC_z,0 \
--n-min 1.0

echo "Calculating RG of population effect with reference EA sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/populationmunged.sumstats.gz,${within_family_path}/processed/reference_samples/ea_ref/ea_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/population_reference_sample

echo "Calculating RG of direct effect with reference EA sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/directmunged.sumstats.gz,${within_family_path}/processed/reference_samples/ea_ref/ea_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/direct_reference_sample

echo "Calculating RG of population effect with direct effect"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/populationmunged.sumstats.gz,${within_family_path}/processed/package_output/ea/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/direct_population

echo "Calculating RG of avg NTC with direct effect"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/ntcmunged.sumstats.gz,${within_family_path}/processed/package_output/ea/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/direct_avgNTC

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/ea/ntcmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/h2_ntc

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/ea/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/direct_h2

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/ea/populationmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/population_h2

# Changing env
source /var/genetics/proj/within_family/snipar_venv/bin/activate
/var/genetics/proj/within_family/snipar_simulate/snipar/scripts/correlate.py  /var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.nfilter \
/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/marginal \
--ldscores /disk/genetics/ukb/jguan/ukb_analysis/output/ldsc/v2/@
