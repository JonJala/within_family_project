#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/dep_ref/DS_Full.sumstats.gz"

##########
# MOBA
#########
python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/sumstats/depanx_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/moba/depsymp" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --info "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/info.formatted.txt.gz" \
    --hwe "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/snpqcstats/sampleQC/hwe.formatted.txt.gz"
# cant compute

####################
# ====== UKB ====== #
####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/sumstats/depressive.symptoms/depressive.symptoms.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/depsymp" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_chromosome 99 \
    --ldsc-ref "$reffile" \
    --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
    --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

