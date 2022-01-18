#!/usr/bin/bash


#############
# LIfelines
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_UNIQUE18.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/cognition18" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population"


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_UNIQUE.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/cognition" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population"
