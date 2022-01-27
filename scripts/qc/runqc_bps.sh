#!/usr/bin/bash

#################
# Minnesotta twins
#################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/BPS_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/bps" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bps_ref/bps_ref.sumstats.gz" \
#     --cptid \
#     --toest "direct_population"

#########
# Hunt
######

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/sbp/sbp_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/sbp" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bps_ref/bps_ref.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "

###############
# Geisinger
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.SBP.all.chr*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/bps" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bps_ref/bps_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population"


