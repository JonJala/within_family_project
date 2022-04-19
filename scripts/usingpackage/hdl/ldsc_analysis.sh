#!/usr/bin/bash

ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/hdl/meta.sumstats \
--out ${within_family_path}/processed/package_output/hdl/directmunged \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/hdl/meta.sumstats \
--out ${within_family_path}/processed/package_output/hdl/populationmunged \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/hdl/meta.sumstats \
--out ${within_family_path}/processed/package_output/hdl/maternalmunged \
--N-col direct_N --p maternal_pval --signed-sumstats maternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/hdl/meta.sumstats \
--out ${within_family_path}/processed/package_output/hdl/paternalmunged \
--N-col direct_N --p paternal_pval --signed-sumstats paternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0



echo "Calcualting RG of population effect with reference HDL sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/hdl/populationmunged.sumstats.gz,${within_family_path}/processed/reference_samples/hdl_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/population_reference_sample
# 0.9389 (0.0107)

echo "Calcualting RG of direct effect with reference HDL sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/hdl/directmunged.sumstats.gz,${within_family_path}/processed/reference_samples/hdl_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/direct_reference_sample
# 0.9389 (0.0107)

echo "Calculating rg between population and direct effects"
Rscript $scriptpath/estimate_marginal_correlations_meta.R \
--file "/var/genetics/proj/within_family/within_family_project/processed/package_output/hdl/meta.sumstats.gz" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/hdl/" \
--merge_alleles ${hm3snps}
# "r=0.7561 S.E.=0.0283"
# hm3
# "r=0.8778 S.E.=0.0163" for direct-population
# r=-0.4494 S.E.=0.0526 for direct-avgparental



${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/hdl/directmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/direct_h2
# 0.204 (0.0164)

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/hdl/populationmunged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/hdl/population_h2
# 0.204 (0.0164)