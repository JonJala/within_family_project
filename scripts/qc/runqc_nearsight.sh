#!/usr/bin/bash
### Run the easyqc pipeline

within_family_path="/var/genetics/proj/within_family/within_family_project"

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/nearsightedness_usual_ext/nearsightedness_usual_chr*_results.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/nearsight" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/nearsight/nearsight_ref.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
    --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT" 