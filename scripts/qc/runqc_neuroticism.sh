#!/usr/bin/bash
### Run the easyqc pipeline

#################
# Minnesotta twins
#################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/STRESS_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/stress" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/neuroticism_ref/neuroticism_ref.sumstats.gz" \
    --cptid \
    --toest "direct_population"


#################
# hunt
#################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/neuroticism/neuroticism_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/neuroticism" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/neuroticism_ref/neuroticism_ref.sumstats.gz" \
    --toest "direct_population"


