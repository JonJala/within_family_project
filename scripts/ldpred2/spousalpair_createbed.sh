#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"

plink1 \
    --bfile /var/genetics/data/ukb/private/latest/processed/user/tamig/projects/GRMMA/data/ukb_chr1_22_geno01_maf001_hwe10e6_500k_removedwithdrawn \
    --keep ${within_family_path}/processed/ldpred2/father.fam \
    --make-bed \
    --out ${within_family_path}/processed/ldpred2/ukb_chr1_22_geno01_maf001_hwe10e6_500k_removedwithdrawn_fathers

plink1 \
    --bfile /var/genetics/data/ukb/private/latest/processed/user/tamig/projects/GRMMA/data/ukb_chr1_22_geno01_maf001_hwe10e6_500k_removedwithdrawn \
    --keep ${within_family_path}/processed/ldpred2/mother.fam \
    --make-bed \
    --out ${within_family_path}/processed/ldpred2/ukb_chr1_22_geno01_maf001_hwe10e6_500k_removedwithdrawn_mothers