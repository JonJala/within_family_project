#!/usr/bin/bash

# ldscpath="/var/genetics/pub/software/ldsc"
ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# /processed/package_output/ea/ea_meta_analysis_newqc_noeb.csv -- median dir-pop rg=0.6413366,0.6413366
# /processed/package_output/ea/ea_meta_analysis_newqc.csv -- median dir-pop rg=0.6649904,0.6649904

# echo "Munging!!"
${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_amat_onpos.csv \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_pop \
--N-col dir_N --p population_pval --signed-sumstats z_population,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_amat_onpos.csv \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_dir \
--N-col N_population --p dir_pval --signed-sumstats z_dir,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0


${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_newqc.csv \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_dir \
--N-col dir_N --p dir_pval --signed-sumstats dir_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

${ldscpath}/munge_sumstats.py \
--sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis_newqc.csv \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_pop \
--N-col population_N --p population_pval --signed-sumstats population_z,0 \
--merge-alleles ${hm3snps} \
--n-min 1.0

echo "Calcualting RG of population effect with reference EA sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_pop.sumstats.gz,${within_family_path}/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/ea_reference_sample



# echo "calculating rg with old meta"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_pop.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_pop.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/pop_old_v_new



${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_dir.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_pop.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/dir_vs_pop \
--intercept-h2 1.0,1.0 \
--intercept-gencov 0.6649904,0.6649904
# 0.5279 (0.0202)


#########################

${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_dir.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_dir.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/dir_old_v_new

