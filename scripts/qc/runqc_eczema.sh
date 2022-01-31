#!/usr/bin/bash
### Run the easyqc pipeline

##############
# Estonian Biobank
##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/Eczema_ext/Eczema_chr*_results.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/eczema" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/eczema_ref/eczema_ref.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population"

#########
# Geisinger
#########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.ECZEMA.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/eczema" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/eczema_ref/eczema_ref.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population"

############
# HUNT
############


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/eczemaEv/eczemaEv_chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/eczemaEv" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/eczema_ref/eczema_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "
