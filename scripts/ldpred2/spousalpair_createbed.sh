#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"

plink1 \
    --bfile /disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3 \
    --keep ${within_family_path}/processed/ldpred2/father.fam \
    --make-bed \
    --out ${within_family_path}/processed/ldpred2/GS_HRC_HM3_fathers

plink1 \
    --bfile /disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3 \
    --keep ${within_family_path}/processed/ldpred2/mother.fam \
    --make-bed \
    --out ${within_family_path}/processed/ldpred2/GS_HRC_HM3_mothers
