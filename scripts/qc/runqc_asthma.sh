#!/usr/bin/bash
### Run the easyqc pipeline

##############
# Estonian Biobank
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/asthma/ASTHMA/ASTHMA_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/asthma" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/asthma_ref/asthma_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population"