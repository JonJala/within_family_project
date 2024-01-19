#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/var/genetics/proj/within_family/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

echo "Munging!!"
${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/metal_output/metal_avgparental_bmi1.tbl \
--out ${within_family_path}/processed/metal_output/metal_avgparental_bmi1_munged \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/metal_output/metal_pop_bmi1.tbl \
--out ${within_family_path}/processed/metal_output/metal_pop_bmi1_munged \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/metal_output/metal_dir_bmi1.tbl \
--out ${within_family_path}/processed/metal_output/metal_dir_bmi1_munged \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/metal_output/metal_avgparental_ea1.tbl \
--out ${within_family_path}/processed/metal_output/metal_avgparental_ea1_munged \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/metal_output/metal_pop_ea1.tbl \
--out ${within_family_path}/processed/metal_output/metal_pop_ea1_munged \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/metal_output/metal_dir_ea1.tbl \
--out ${within_family_path}/processed/metal_output/metal_dir_ea1_munged \
--merge-alleles ${hm3snps} \
--n-min 1.0

echo "Running LDSC"
echo "Analyzing Genetic Correlation between EA Dir and EA Population"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_ea1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_pop_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/ea_dir_pop_cons \
--intercept-h2 1.0,1.0

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_ea1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_pop_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/ea_dir_pop



echo "Analyzing Genetic Correlation between EA Dir and EA Average Parental"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_ea1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_avgparental_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/ea_dir_avgparental_cons \
--intercept-h2 1.0,1.0


echo "Analyzing Genetic Correlation between EA Dir and EA Average Parental"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_ea1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_avgparental_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/ea_dir_avgparental


echo "Analyzing Genetic Correlation between BMI Dir and BMI Population"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_pop_bmi1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_dir_pop_cons \
--intercept-h2 1.0,1.0

echo "Analyzing Genetic Correlation between BMI Dir and BMI Population"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_pop_bmi1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_dir_pop


echo "Analyzing Genetic Correlation between BMI Dir and BMI Average Parental"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_avgparental_bmi1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_dir_avgparental_cons \
--intercept-h2 1.0,1.0

echo "Analyzing Genetic Correlation between BMI Dir and BMI Average Parental"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_avgparental_bmi1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_dir_avgparental


echo "Calculating Genetic Correlation between EA Dir and BMI Dir"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_dir_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ea_dir_cons \
--intercept-h2 1.0,1.0


echo "Calculating Genetic Correlation between EA Dir and BMI Dir"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_dir_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_dir_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ea_dir

echo "Calculating Genetic Correlation between EA Avg Parental and BMI Avg Parental"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_avgparental_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_avgparental_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ea_avgparental_cons \
--intercept-h2 1.0,1.0

echo "Calculating Genetic Correlation between EA Avg Parental and BMI Avg Parental"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_avgparental_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_avgparental_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ea_avgparental


echo "Calculating Genetic Correlation between EA Pop and BMI Pop"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_pop_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_pop_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ea_pop_cons \
--intercept-h2 1.0,1.0

echo "Calculating Genetic Correlation between EA Pop and BMI Pop"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_pop_bmi1_munged.sumstats.gz,${within_family_path}/processed/metal_output/metal_pop_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ea_pop


echo "Calculating Genetic Correlation between EA pop with reference EA"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_pop_ea1_munged.sumstats.gz,${within_family_path}/processed/ea_ref/ea_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/ea_ref_cons \
--intercept-h2 1.0,1.0

echo "Calculating Genetic Correlation between EA pop with reference EA"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_pop_ea1_munged.sumstats.gz,${within_family_path}/processed/ea_ref/ea_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/ea_ref

echo "Calculating Genetic Correlation between BMI Pop and Reference BMI"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_pop_bmi1_munged.sumstats.gz,${within_family_path}/processed/bmi_ref/bmi_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ref_cons \
--intercept-h2 1.0,1.0

echo "Calculating Genetic Correlation between BMI Pop and Reference BMI"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/metal_output/metal_pop_bmi1_munged.sumstats.gz,${within_family_path}/processed/bmi_ref/bmi_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ref


echo "Calculating Genetic Correlation between EA ref and BMI ref"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/ea_ref/ea_ref.sumstats.gz,${within_family_path}/processed/bmi_ref/bmi_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ea_ref

echo "Calculating Genetic Correlation between EA ref and BMI ref"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/ea_ref/ea_ref.sumstats.gz,${within_family_path}/processed/bmi_ref/bmi_ref.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/metal_ldsc/bmi_ea_ref_cons \
--intercept-h2 1.0,1.0
