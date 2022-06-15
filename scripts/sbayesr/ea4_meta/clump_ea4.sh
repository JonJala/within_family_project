#!/usr/bin/bash

for chr in {1..22}; do
    plink1 --bfile /disk/genetics2/HRC/aokbay/LDgf/Full/perChr_rsid/HRC_geno05_mind01_maf001_hwe1e-10_rel025_nooutliers_chr$chr \
    --clump /disk/genetics4/projects/EA4/derived_data/Meta_analysis/1_Main/2020_08_20/output/EA4_2020_08_20.meta \
    --clump-snp-field rsID \
    --clump-p1 5e-8 \
    --clump-p2 5e-8 \
    --clump-field P \
    --clump-r2 0.1 \
    --clump-kb 1000000 \
    --out /var/genetics/proj/within_family/within_family_project/processed/ea4_meta/EA4_2020_08_20.meta.chr$chr &
done
wait