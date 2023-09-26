#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/prscs/prscsfunc.sh

# ============= Execution ============= #

## MCS
run_pgi "${within_family_path}/processed/package_output/ea/meta.sumstats.gz" "direct" "ea" "mcs"
run_pgi "${within_family_path}/processed/package_output/ea/meta.sumstats.gz" "population" "ea" "mcs"

## UKB
run_pgi "${within_family_path}/processed/package_output/ea/meta_noukb.sumstats.gz" "direct" "ea" "ukb"
run_pgi "${within_family_path}/processed/package_output/ea/meta_noukb.sumstats.gz" "population" "ea" "ukb"
