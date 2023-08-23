#!/usr/bin/bash

# -------------------------------------------------------------------------------------------
# description: filter bgen to sample and snps of interest for howe et al info score analysis
# -------------------------------------------------------------------------------------------

keep_dir=/disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/keep

for snp_list in "$keep_dir"/* 
do 
    
    filename=${snp_list##*/}
    file=${filename%.*}

    plink2 --bgen /disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_imp_chr1_v3.bgen ref-first \
            --sample /disk/genetics2/ukb/orig/UKBv3/sample/ukb11425_imp_chr1_22_v3_s487395.sample \
            --keep /disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/all_sibs.txt \
            --extract ${snp_list} \
            --export A \
            --make-pgen \
            --out /disk/genetics/data/ukb/private/latest/processed/proj/within_family/howe_info_analysis/plink_out/${file}

done