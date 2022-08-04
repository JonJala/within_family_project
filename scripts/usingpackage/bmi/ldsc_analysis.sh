#!/usr/bin/bash

ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/var/genetics/proj/within_family/within_family_project/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"
source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/bmi/directmunged \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/bmi/populationmunged \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/bmi/maternalmunged \
--N-col direct_N --p maternal_pval --signed-sumstats maternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/meta.nfilter.sumstats.gz \
--out ${within_family_path}/processed/package_output/bmi/paternalmunged \
--N-col direct_N --p paternal_pval --signed-sumstats paternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0



echo "Calcualting RG of population effect with reference BMI sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bmi/populationmunged.sumstats.gz,${within_family_path}/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bmi/population_reference_sample
# 0.9389 (0.0107)

echo "Calcualting RG of direct effect with reference BMI sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bmi/directmunged.sumstats.gz,${within_family_path}/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bmi/direct_reference_sample
# 0.9389 (0.0107)



${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/bmi/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bmi/direct_h2
# 0.204 (0.0164)

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/bmi/populationmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bmi/population_h2
# 0.204 (0.0164)

# Changing env
source /var/genetics/proj/within_family/within_family_project/snipar/bin/activate
/var/genetics/proj/within_family/within_family_project/snipar/snipar/scripts/correlate.py  /var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/meta.nfilter \
/var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/marginal \
--ldscores /disk/genetics/ukb/alextisyoung/hapmap3/ldscores/@