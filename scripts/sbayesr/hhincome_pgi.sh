#!/usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /var/genetics/proj/ea4/code/PGS/7_PGS_SBayesR.sh

within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sbayesrfunc.sh

# ============= Execution ============= #
run_pgi "${within_family_path}/processed/package_output/hhincome/meta.hm3.sumstats.gz" "direct" "hhincome" "mcs"
run_pgi "${within_family_path}/processed/package_output/hhincome/meta.hm3.sumstats.gz" "population" "hhincome" "mcs"