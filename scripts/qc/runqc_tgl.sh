#!/usr/bin/bash


#############
# LIfelines
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_TGL18.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/tgl18" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/tgl_ref/tgl_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population"


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_TGL.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/tgl" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ldl_ref/ldl_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population"
