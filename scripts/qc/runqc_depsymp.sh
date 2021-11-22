#!/usr/bin/bash
### Run the easyqc pipeline

##########
# MOBA
#########
python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/sumstats/depanx_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/moba/depsymp" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/dep_ref/DS_Full.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population"
# cant compute


