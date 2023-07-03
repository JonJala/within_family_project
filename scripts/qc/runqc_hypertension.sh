#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/bps_ref/bps_ref.sumstats.gz"

############
# Finn Gen
############

## 6/19/2023 : This data will hopefully be moved from private to public, and it's likely OK to use it this way, but this is an issue that does need to be resolved in a more permanent way. This code / paradigm shouldn't be copy-pasted or used elsewhere as-is

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finngen/private/v1/processed/sumstats/hypertension.sumstats.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/finngen/hypertension" \
    --effects "direct_averageparental" \
    --ldsc-ref $reffile \
    --toest "direct_population" \
    --binary
