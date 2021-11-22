#!/usr/bin/bash

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_formetanalysis.sumstats" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ea4/" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
    --phvar 1