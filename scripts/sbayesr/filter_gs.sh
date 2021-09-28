#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"
gsbed="/disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3"


plink1 --bfile $gsbed \
        --no-pheno \
        --hwe 1e-6 \
        --maf 0.01 \
        --make-bed \
        --out "$within_family_path/processed/sbayesr/referenceld/gs/tmp/gsbed_tmp"