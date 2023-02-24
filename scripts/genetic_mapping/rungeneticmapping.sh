#!/usr/bin/bash

python /var/genetics/proj/within_family/within_family_project/scripts/genetic_mapping/makegeneticmap.py \
    "/var/genetics/proj/within_family/snipar/snipar/util_data/decode_map/chr_~.gz" \
    --sumstat "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/meta.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/"