#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/prscs/prscsfunc.sh

# ============= Execution ============= #
run_pgi "${within_family_path}/processed/package_output/bmi/meta.sumstats.gz" "direct" "bmi" "mcs"
run_pgi "${within_family_path}/processed/package_output/bmi/meta.sumstats.gz" "population" "bmi" "mcs"