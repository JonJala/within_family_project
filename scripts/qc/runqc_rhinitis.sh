#!/usr/bin/bash

#########
# Hunt
######


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/rhinitisEv/rhinitisEv_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/rhinitis" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/rhinitis_ref/rhinitis_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "
