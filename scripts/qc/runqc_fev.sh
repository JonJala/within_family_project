#!/usr/bin/bash

# #########
# # Hunt
# #######


# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/fev1/fev1_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/fev1" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/fev1_ref/fev1_ref.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
#     --info '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/info.formatted.gz' \
#     --hwe '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/hwe.formatted.gz'


# ###############
# # Geisinger
# ##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.FEV1.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/fev" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/fev1_ref/fev1_ref.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --info '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/info.formatted.txt' \
#     --hwe '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/hwe.formatted.txt'

#####################
# ====== UKB ====== #
#####################

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics3/data_dirs/ukb/private/v3/processed/sumstats/fgwas/Imp_FEV1.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/fev" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --bim_chromosome 99 \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/fev1_ref/fev1_ref.sumstats.gz" \
    --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
    --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted'


# #######################
# # generation scotland
# #######################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/4/chr_*.sumstatschr_clean.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/gs/fev" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/fev1_ref/fev1_ref.sumstats.gz" \
#     --rsid_readfrombim "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/SNPs/chr_*_rsids.txt,0,3,1, " \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --hwe "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/hwe/chr_*.hwe" \
#     --info "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/info/combined_clean.info.gz"
