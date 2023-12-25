#!/usr/bin/bash

ldscpath="/disk/genetics/tools/ldsc/ldsc"
ldscmodpath="/var/genetics/proj/within_family/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"

source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/hdl/meta_adj_se.sumstats.gz \
--out ${within_family_path}/processed/package_output/hdl/directmunged \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/hdl/meta_adj_se.sumstats.gz \
--out ${within_family_path}/processed/package_output/hdl/populationmunged \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/hdl/meta_adj_se.sumstats.gz \
--out ${within_family_path}/processed/package_output/hdl/maternalmunged \
--N-col direct_N --p maternal_pval --signed-sumstats maternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/hdl/meta_adj_se.sumstats.gz \
--out ${within_family_path}/processed/package_output/hdl/paternalmunged \
--N-col direct_N --p paternal_pval --signed-sumstats paternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0



echo "Calculating RG of population effect with reference HDL sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/hdl/populationmunged.sumstats.gz,${within_family_path}/processed/reference_samples/hdl_ref/hdl_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/population_reference_sample

echo "Calculating RG of direct effect with reference HDL sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/hdl/directmunged.sumstats.gz,${within_family_path}/processed/reference_samples/hdl_ref/hdl_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/direct_reference_sample

echo "Calculating RG of population effect with direct effect"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/hdl/populationmunged.sumstats.gz,${within_family_path}/processed/package_output/hdl/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/direct_population

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/hdl/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/direct_h2

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/hdl/populationmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/population_h2

# Changing env
source /var/genetics/proj/within_family/snipar_venv/bin/activate
/var/genetics/proj/within_family/snipar_simulate/snipar/scripts/correlate.py /var/genetics/proj/within_family/within_family_project/processed/package_output/hdl/meta_adj_se \
/var/genetics/proj/within_family/within_family_project/processed/package_output/hdl/marginal \
--ldscores /disk/genetics/ukb/jguan/ukb_analysis/output/ldsc/v2/@
