#!/usr/bin/bash


within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/prscs/prscsfunc.sh

# ============= Execution ============= #
## MCS
run_pgi "${within_family_path}/processed/package_output/height/meta.sumstats.gz" "direct" "height" "mcs"
run_pgi "${within_family_path}/processed/package_output/height/meta.sumstats.gz" "population" "height" "mcs"

## UKB
run_pgi "${within_family_path}/processed/package_output/height/meta_noukb.sumstats.gz" "direct" "height" "ukb"
run_pgi "${within_family_path}/processed/package_output/height/meta_noukb.sumstats.gz" "population" "height" "ukb"
