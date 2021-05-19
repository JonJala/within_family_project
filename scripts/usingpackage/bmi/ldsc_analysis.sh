#!/usr/bin/bash

ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

echo "Munging!!"
${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/bmi_meta.csv \
--out ${within_family_path}/processed/package_output/bmi/meta_analysis_pop \
--N-col wt_2 --p pval_population --signed-sumstats z_population,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/bmi_meta.csv \
--out ${within_family_path}/processed/package_output/bmi/meta_analysis_dir \
--N-col wt_dir --p pval_dir --signed-sumstats z_dir,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0


${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/bmi/bmi_meta.csv \
--out ${within_family_path}/processed/package_output/bmi/meta_analysis_avgparental \
--N-col wt_2 --p pval_avgparental --signed-sumstats z_avgparental,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0


echo "Calcualting RG of population effect with reference BMI sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bmi/meta_analysis_pop.sumstats.gz,${within_family_path}/processed/bmi_ref/Meta-analysis_Locke_et_al+UKBiobank_2018_UPDATED.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/notebooks/creating_package/bmi/bmi_reference_sample


${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bmi/meta_analysis_dir.sumstats.gz,${within_family_path}/processed/metal_output/metal_dir_bmi1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/notebooks/creating_package/bmi/metal_dir


echo "Calculating rg between population and direct effects"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/bmi/meta_analysis_dir.sumstats.gz,${within_family_path}/processed/package_output/bmi/meta_analysis_pop.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/notebooks/creating_package/bmi/dir_pop \
--intercept-h2 1.0,1.0 \
--intercept-gencov 0.6660485401777425,0.6660485401777425