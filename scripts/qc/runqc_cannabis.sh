#!/usr/bin/bash
reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/cannabis_ref/cannabis_ref.sumstats.gz" 


#############
# Dutch Twins
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Cannabis/NTR_Cannabis_CHR*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/cannabis" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --cptid \
    --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
    --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"

#####################
# ====== UKB ====== #
#####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/sumstats/ever.cannabis/ever.cannabis.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/cannabis" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_chromosome 99 \
    --ldsc-ref $reffile \
    --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
    --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'
