#!/usr/bin/bash

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/health_ref/health_ref.sumstats.gz"

# ###############
# # HUNT
# ###############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/health/health_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/health" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
#     --info '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/info.formatted.gz' \
#     --hwe '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/hwe.formatted.gz'


# ##########
# # STR
# ##########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SRH/SRH_chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/SRH" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_population" \
#     --bim_bp 3 --bim_a1 4 --bim_a2 5 \
#     --info "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/info.txt.gz" \
#     --hwe "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/hardy.txt.gz" \
#     --rsid_readfrombim "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPs/chr_*.bim,0,3,1, "

# #############
# # Dutch Twins
# #############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/SelfRatedHealth/NTR_SRH_CHR*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/srh" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid \
#     --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
#     --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"


# #####################
# # ====== UKB ====== #
# #####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/sumstats/self.rated.health/self.rated.health.sumstats.gz" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/srh" \
#     --effects "direct_averageparental" \
#     --toest "direct_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref $reffile \
#     --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
#     --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

# #####################
# # ====== FHS ====== #
# #####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/disk/genetics3/data_dirs/fhs/public/v1/processed/sumstats/gwas/srh/chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/fhs/health" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --ldsc-ref $reffile \
#     --cptid

#####################
# ====== CKB ====== #
#####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/raw/self_rated_health.sumstats.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/health" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --ldsc-ref "$reffile" \
    --cptid