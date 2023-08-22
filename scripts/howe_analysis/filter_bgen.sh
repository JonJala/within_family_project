#!/usr/bin/bash

## ---------------------------------------------------------------------
## description: filter bgen to sample and snps of interest
## ---------------------------------------------------------------------

## low info snps
plink2 --bgen /disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_imp_chr1_v3.bgen ref-first \
    --sample /disk/genetics2/ukb/orig/UKBv3/sample/ukb11425_imp_chr1_22_v3_s487395.sample \
    --keep /disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs.txt \
    --extract /disk/genetics4/ukb/tammytan/wf/howe_analysis/low_info_snps.txt \
    --make-bed \
    --out /disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs_low_info

# ## high info SNPs
# plink2 --bgen /disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_imp_chr1_v3.bgen ref-first \
#     --sample /disk/genetics2/ukb/orig/UKBv3/sample/ukb11425_imp_chr1_22_v3_s487395.sample \
#     --keep /disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs.txt \
#     --extract /disk/genetics4/ukb/tammytan/wf/howe_analysis/high_info_snps.txt \
#     --make-bed \
#     --out /disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs_high_info