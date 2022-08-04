#!/usr/bin/bash

# ldscpath="/var/genetics/pub/software/ldsc"
ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/var/genetics/proj/within_family/within_family_project/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"

source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/eversmoker/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/eversmoker/directmunged \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/eversmoker/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/eversmoker/populationmunged \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/eversmoker/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/eversmoker/paternalmunged \
--N-col direct_N --p paternal_pval --signed-sumstats paternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/eversmoker/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/eversmoker/maternalmunged \
--N-col direct_N --p maternal_pval --signed-sumstats maternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py /
--sumstats ${within_family_path}/processed/package_output/eversmoker/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/eversmoker/ntcmunged \
--N-col direct_N --p avg_NTC_pval --signed-sumstats avg_NTC_z,0 \
--merge-alleles ${hm3snps}

echo "Calcualting RG of population effect with reference dpression sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/eversmoker/populationmunged.sumstats.gz,${within_family_path}/processed/reference_samples/smoking_ref/Smokinginit.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/eversmoker/population_reference_sample

echo "Calcualting RG of direct effect with reference eversmoker sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/eversmoker/directmunged.sumstats.gz,${within_family_path}/processed/reference_samples/smoking_ref/Smokinginit.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/eversmoker/direct_reference_sample
# 1.0353 (0.0159)

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/eversmoker/paternalmunged.sumstats.gz,${within_family_path}/processed/package_output/depression/maternalmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/eversmoker/maternal_vs_paternal
# -0.0501 (0.3567)


${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/eversmoker/ntcmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/eversmoker/h2_ntc
# 0.0367 (0.0072)


Rscript $scriptpath/estimate_marginal_correlations_meta.R \
--file "/var/genetics/proj/within_family/within_family_project/processed/package_output/eversmoker/meta.sumstats.gz" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/eversmoker/paternal_maternal" \
--dir_pop_rg_name "paternal_maternal_rg" --dirbeta "paternal_Beta" --popbeta "maternal_Beta" \
--dirse "paternal_SE" --popse "maternal_SE" \
--merge_alleles ${hm3snps}
# 0.204 (0.0164) # r=1.9783 S.E.=0.2345

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/eversmoker/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/eversmoker/direct_h2

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/eversmoker/populationmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/eversmoker/population_h2

# Changing env
source /var/genetics/proj/within_family/within_family_project/snipar/bin/activate
/var/genetics/proj/within_family/within_family_project/snipar/snipar/scripts/correlate.py   /var/genetics/proj/within_family/within_family_project/processed/package_output/eversmoker/meta.nfilter \
/var/genetics/proj/within_family/within_family_project/processed/package_output/eversmoker/marginal \
--ldscores /disk/genetics/ukb/alextisyoung/hapmap3/ldscores/@