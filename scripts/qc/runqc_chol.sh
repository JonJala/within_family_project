#!/usr/bin/bash


#############
# LIfelines
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_CHO18.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/cho18" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/cholestrol_ref/cholestrol_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population"


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_CHO.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/cho" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/cholestrol_ref/cholestrol_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population"
