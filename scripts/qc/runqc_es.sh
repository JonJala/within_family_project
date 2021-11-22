#!/usr/bin/bash
### Run the easyqc pipeline
# Ever smoker

#################
# Minnesotta twins
#################


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/ES_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/es" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/smoking_ref/Smokinginit.sumstats.gz" \
    --cptid \
    --toest "direct_population"