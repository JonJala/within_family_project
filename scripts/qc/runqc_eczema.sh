#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/eczema_ref/eczema_ref.sumstats.gz"

# ##############
# # Estonian Biobank
# ##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/Eczema_ext/Eczema_chr*_results.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/eczema" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
#     --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT" \
#     --binary

# #########
# # Geisinger
# #########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.ECZEMA.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/eczema" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --info '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/info.formatted.txt' \
#     --hwe '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/hwe.formatted.txt' \
#     --binary

# ############
# # HUNT
# ############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/eczemaEv/eczemaEv_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/eczema" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, " \
#     --info '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/info.formatted.gz' \
#     --hwe '/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/snpstats/hwe.formatted.gz' \
#     --binary

################
# iPSYCH
############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ipsych/private/v1/processed/sumstats/sumstats_eczema_export0.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ipsych/eczema" \
    --toest "direct_population" \
    --cptid \
    --ldsc-ref "$reffile" \
    --binary

# #####################
# # ====== UKB ====== #
# #####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/private/v3/processed/proj/within_family/sumstats/ECZEMA/ECZEMA.sumstats.gz" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/eczema" \
#     --effects "direct_averageparental" \
#     --toest "direct_population" \
#     --bim_chromosome 99 \
#     --ldsc-ref "$reffile" \
#     --hwe '/disk/genetics/ukb/alextisyoung/hapmap3/hwe/hwe.formatted' \
#     --info '/disk/genetics2/ukb/orig/UKBv3/imputed_data/info.formatted' \
#     --binary