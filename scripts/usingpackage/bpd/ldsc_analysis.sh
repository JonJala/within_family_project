#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/var/genetics/proj/within_family/within_family_project/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"
refsample="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bpd_ref/bpd_ref.sumstats.gz"

source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

echo "Munging!!"
${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bpd/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/bpd/populationmunged \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bpd/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/bpd/directmunged \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

echo "Calcualting RG of population effect with reference sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bpd/populationmunged.sumstats.gz,${refsample} \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bpd/population_reference_sample
# 0.901 (0.0059)

echo "Calcualting RG of direct effect with reference sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bpd/directmunged.sumstats.gz,${refsample} \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bpd/direct_reference_sample
# 0.901 (0.0059)


${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/bpd/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bpd/direct_h2
#  0.3274 (0.0175)

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/bpd/populationmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bpd/population_h2
#  0.3274 (0.0175)


# Changing env
source /var/genetics/proj/within_family/snipar/bin/activate
/var/genetics/proj/within_family/snipar/snipar/scripts/correlate.py /var/genetics/proj/within_family/within_family_project/processed/package_output/bpd/meta.nfilter \
/var/genetics/proj/within_family/within_family_project/processed/package_output/bpd/marginal \
--ldscores /disk/genetics/ukb/alextisyoung/hapmap3/ldscores/@