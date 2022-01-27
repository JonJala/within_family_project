#!/usr/bin/bash

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/migarine_ref/migraine_ref.sumstats.gz"

################
# Geisinger
############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.MIGRAINE.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/migraine" \
#     --ldsc-ref $reffile \
#     --toest "direct_paternal_maternal_averageparental_population"

##############
# Estonian Biobank
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/Migraine_ext/Migraine_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/migraine" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population"

