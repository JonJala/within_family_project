#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/prscs/prscsfunc.sh

# ============= Execution ============= #

## MCS
run_pgi "${within_family_path}/processed/package_output/cognition/meta.sumstats.gz" "direct" "cognition" "mcs"
run_pgi "${within_family_path}/processed/package_output/cognition/meta.sumstats.gz" "population" "cognition" "mcs"

## UKB
run_pgi "${within_family_path}/processed/package_output/cognition/meta_noukb.sumstats.gz" "direct" "cognition" "ukb"
run_pgi "${within_family_path}/processed/package_output/cognition/meta_noukb.sumstats.gz" "population" "cognition" "ukb"