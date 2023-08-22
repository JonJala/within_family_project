#!/usr/bin/bash

## ---------------------------------------------------------------------
## description: filter bgen to sample and snps of interest
## ---------------------------------------------------------------------

# # filter bgen to first sib in pair and SNPs of interest
# plink2 --bgen /disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_imp_chr1_v3.bgen ref-first \
#     --sample /disk/genetics2/ukb/orig/UKBv3/sample/ukb11425_imp_chr1_22_v3_s487395.sample \
#     --keep /disk/genetics4/ukb/tammytan/wf/howe_analysis/sib1.txt \
#     --extract /disk/genetics4/ukb/tammytan/wf/howe_analysis/snps.txt \
#     --make-bed \
#     --out /disk/genetics4/ukb/tammytan/wf/howe_analysis/sib1

# # filter bgen to second sib in pair and SNPs of interest
# plink2 --bgen /disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_imp_chr1_v3.bgen ref-first \
#     --sample /disk/genetics2/ukb/orig/UKBv3/sample/ukb11425_imp_chr1_22_v3_s487395.sample \
#     --keep /disk/genetics4/ukb/tammytan/wf/howe_analysis/sib2.txt \
#     --extract /disk/genetics4/ukb/tammytan/wf/howe_analysis/snps.txt \
#     --make-bed \
#     --out /disk/genetics4/ukb/tammytan/wf/howe_analysis/sib2


## test for high info SNPs
plink2 --bgen /disk/genetics2/ukb/orig/UKBv3/imputed_data/ukb_imp_chr1_v3.bgen ref-first \
    --sample /disk/genetics2/ukb/orig/UKBv3/sample/ukb11425_imp_chr1_22_v3_s487395.sample \
    --keep /disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs.txt \
    --extract /disk/genetics4/ukb/tammytan/wf/howe_analysis/high_info_snps.txt \
    --make-bed \
    --out /disk/genetics4/ukb/tammytan/wf/howe_analysis/all_sibs_high_info