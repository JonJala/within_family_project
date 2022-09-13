#!/usr/bin/bash


# #############
# # Lifelines
# ##########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_UNIQUE18.sumstats.gz" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/cognition18" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
#     --effects "direct_averageparental" \
#     --toest "direct_population" \
#     --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
#     --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"


# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_UNIQUE.sumstats.gz" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/cognition" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
#     --effects "direct_averageparental" \
#     --toest "direct_population" \
#     --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
#     --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"

#####################
# ====== UKB ====== #
#####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics3/data_dirs/ukb/private/v3/processed/sumstats/fgwas/Imp_Cognitive.ability.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/cognition" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_chromosome 99 \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
    --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
    --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'

# #######################
# # generation scotland
# #######################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/8/chr_*.sumstatschr_clean.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/gs/cognition" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
#     --rsid_readfrombim "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/SNPs/chr_*_rsids.txt,0,3,1, " \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --hwe "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/hwe/chr_*.hwe" \
#     --info "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/info/combined_clean.info.gz"

# #################
# # Minnesota twins
# #################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/IQ_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/iq" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
#     --cptid \
#     --toest "direct_population" \
#     --hwe '/disk/genetics3/data_dirs/minn_twins/public/v1/raw/sumstats/fgwas/sumstats/snpstats/hardy.hwe'

# ##########
# # STR
# ##########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/stdIQ/stdIQ_chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/IQ" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
#     --toest "direct_population" \
#     --bim_bp 3 --bim_a1 4 --bim_a2 5 \
#     --info "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/info.txt.gz" \
#     --hwe "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPstats/hardy.txt.gz" \
#     --rsid_readfrombim "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/SNPs/chr_*.bim,0,3,1, "

# #####
# # Finnish twins
# #####

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/IQ.chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/iq" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/intelligence_ref/intelligence_ref.sumstats.gz" \
#     --toest "direct_population" \
#     --hwe /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe \
#     --info /var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt
