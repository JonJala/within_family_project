#!/usr/bin/bash


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/21/chr_*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/scratch/easyqc_tests/" \
    --toest "full_averageparental_population" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz"
    