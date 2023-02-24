#!/usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /var/genetics/proj/ea4/code/PGS/7_PGS_SBayesR.sh

within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sbayesrfunc.sh

# ============= Execution ============= #
run_pgi "${within_family_path}/processed/package_output/extraversion/meta.hm3.sumstats.gz" "direct" "extraversion" "mcs"
run_pgi "${within_family_path}/processed/package_output/extraversion/meta.hm3.sumstats.gz" "population" "extraversion" "mcs"