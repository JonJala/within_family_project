#!/usr/bin/bash
### Run the easyqc pipeline

##############
# Estonian Biobank
##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/hayfever/Hayfever/hayfever_chr*_results.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/hayfever" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/hayfever_ref/hayfever_ref.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population"

###############
# Geisinger
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.HAYFEVER.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/hayfever" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/hayfever_ref/hayfever_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population"

