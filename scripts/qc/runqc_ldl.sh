#!/usr/bin/bash


#############
# LIfelines
##########

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_LDC18.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/ldl18" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ldl_ref/ldl_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_LDC.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/ldl" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ldl_ref/ldl_ref.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"

#########
# Hunt
######


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/hdl_non/hdl_non_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/hdl_non" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ldl_ref/ldl_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "

###############
# Geisinger
##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.nonHDL.all.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/hdl_non" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ldl_ref/ldl_ref.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population"

