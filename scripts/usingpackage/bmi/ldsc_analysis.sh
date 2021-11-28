#!/usr/bin/bash

ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/bmi_meta.sumstats \
--out ${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_dir \
--N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/bmi_meta.sumstats \
--out ${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_pop \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/bmi_meta.sumstats \
--out ${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_maternal \
--N-col direct_N --p maternal_pval --signed-sumstats maternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/bmi_meta.sumstats \
--out ${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_paternal \
--N-col direct_N --p paternal_pval --signed-sumstats paternal_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0



echo "Calcualting RG of population effect with reference BMI sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_pop.sumstats.gz,${within_family_path}/processed/reference_samples/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bmi/bmi_reference_sample
# 0.9389 (0.0107)


echo "Calculating rg between population and direct effects"
Rscript $scriptpath/estimate_marginal_correlations_meta.R \
--file "/var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/bmi_meta.sumstats" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/bmi/"
# "r=0.7561 S.E.=0.0283" for direct-population
# r=-0.4494 S.E.=0.0526 for direct-avgparental

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_maternal.sumstats.gz,${within_family_path}/processed/package_output/bmi/meta_analysis_neq_qc_paternal.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/bmi/maternal_vs_paternal