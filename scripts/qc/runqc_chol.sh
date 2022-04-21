#!/usr/bin/bash


#############
# LIfelines
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_CHO18.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/cho18" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/cholestrol_ref/cholestrol_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_CHO.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/cho" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/cholestrol_ref/cholestrol_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"
