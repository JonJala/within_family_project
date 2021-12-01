#!/usr/bin/bash
### Run the easyqc pipeline

##############
# Estonian Biobank
##############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/eczema/Eczema/Eczema_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/eczema" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/eczema_ref/eczema_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population"