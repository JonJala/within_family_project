#!/usr/bin/bash
### Run the easyqc pipeline

#################
# Minnesotta twins
#################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/SWB_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/swb" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/swb_ref/swb_ref.sumstats.gz" \
    --cptid \
    --toest "direct_population"
# 0.6795 (0.3074)