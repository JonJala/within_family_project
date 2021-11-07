#!/usr/bin/bash

ldscpath="/var/genetics/pub/software/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

echo "Munging!!"
# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/height/height_meta.csv \
# --out ${within_family_path}/processed/package_output/height/height_meta_pop \
# --N-col population_N --p population_pval --signed-sumstats population_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/height/height_meta.csv \
# --out ${within_family_path}/processed/package_output/height/height_meta_dir \
# --N-col dir_N --p dir_pval --signed-sumstats dir_z,0 \
# --merge-alleles ${hm3snps} \
# --n-min 1.0

echo "Calcualting RG of population effect with reference sample"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/height/height_meta_pop.sumstats.gz,${within_family_path}/processed/reference_samples/ht_ref/Meta-analysis_Wood_et_al+UKBiobank_2018.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/height/ht_ref_sample
#0.8895 (0.0062)

echo "Calculating rg between population and direct effects"
${ldscpath}/ldsc.py \
--rg ${within_family_path}/processed/package_output/height/height_meta_dir.sumstats.gz,${within_family_path}/processed/package_output/height/height_meta_pop.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/height/height_dir_pop \
--intercept-h2 1.0,1.0 \
--intercept-gencov 0.5944471217491667,0.5944471217491667
#  0.839 (0.0071)