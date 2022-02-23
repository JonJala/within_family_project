#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"
${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/height/meta.sumstats \
--out ${within_family_path}/processed/package_output/height/populationmunged \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/height/meta.sumstats \
--out ${within_family_path}/processed/package_output/height/directmunged \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

echo "Calcualting RG of population effect with reference sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/height/populationmunged.sumstats.gz,${within_family_path}/processed/reference_samples/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/height/population_reference_sample
# 0.901 (0.0059)

echo "Calcualting RG of direct effect with reference sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/height/directmunged.sumstats.gz,${within_family_path}/processed/reference_samples/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/height/direct_reference_sample
# 0.901 (0.0059)

# echo "Calculating rg between population and direct effects"
# Rscript $scriptpath/estimate_marginal_correlations_meta.R \
# --file "${within_family_path}/processed/package_output/height/meta.sumstats" \
# --outprefix "${within_family_path}/processed/package_output/height/" \
# --merge_alleles ${hm3snps}
#  "r=0.8354 S.E.=0.0125"
#  "r=-0.0107 S.E.=0.0419"
# hm3
# "r=0.8747 S.E.=0.0092"


# ${ldscpath}/ldsc.py \
# --h2 ${within_family_path}/processed/package_output/height/directmunged.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/package_output/height/direct_h2
# #  0.3274 (0.0175)

# ${ldscpath}/ldsc.py \
# --h2 ${within_family_path}/processed/package_output/height/populationmunged.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/package_output/height/population_h2
# #  0.3274 (0.0175)
