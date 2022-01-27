#!/usr/bin/bash

#########
# Hunt
#######


# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/fev1/fev1_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/fev1" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/fev1_ref/fev1_ref.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "

###############
# Geisinger
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.FEV1.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/fev" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/fev1_ref/fev1_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population"
