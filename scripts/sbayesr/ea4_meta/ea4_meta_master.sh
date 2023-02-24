#!/usr/bin/bash

Rscript /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/ea4_meta/process_ea_sumstats.r

bash /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/ea4_meta/ea4_meta_pgi.sh

source /var/genetics/proj/within_family/snipar/bin/activate

bash /var/genetics/proj/within_family/within_family_project/scripts/fpgs/fpgs_ea.sh