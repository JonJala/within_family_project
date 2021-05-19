#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# echo "Munging!!"
# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.csv \
# --out ${within_family_path}/processed/package_output/ea/meta_analysis_pop \
# --N-col wt_2 --p pval_population --signed-sumstats z_population,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.csv \
# --out ${within_family_path}/processed/package_output/ea/meta_analysis_dir \
# --N-col wt_dir --p pval_dir --signed-sumstats z_dir,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0


# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/ea_meta_analysis.csv \
# --out ${within_family_path}/processed/package_output/ea/meta_analysis_avgparental \
# --N-col wt_2 --p pval_avgparental --signed-sumstats z_avgparental,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

echo "Calcualting RG of population effect with reference EA sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_pop.sumstats.gz,${within_family_path}/processed/ea_ref/GWAS_EA_excl23andMe.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/ea_reference_sample


${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/ea/meta_analysis_dir.sumstats.gz,${within_family_path}/processed/metal_output/metal_dir_ea1_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/metal_dir


# echo "Calculating rg between population and direct effects"
# ${ldscpath}/ldsc.py \
# --rg ${within_family_path}/processed/package_output/ea/meta_analysis_dir.sumstats.gz,${within_family_path}/processed/package_output/ea/meta_analysis_pop.sumstats.gz \
# --ref-ld-chr ${eur_w_ld_chr} \
# --w-ld-chr ${eur_w_ld_chr} \
# --out ${within_family_path}/processed/package_output/ea/ea_dir_pop \
# --intercept-h2 1.0,1.0 \
# --intercept-gencov 0.6349009746076841,0.6349009746076841