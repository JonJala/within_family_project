#!/usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /disk/genetics4/projects/EA4/code/PGS/7_PGS_SBayesR.sh

within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sbayesrfunc.sh

# ============= Execution ============= #
run_pgi "${within_family_path}/processed/package_output/eversmoker/meta.hm3.sumstats.gz" "direct" "eversmoker" "mcs"
run_pgi "${within_family_path}/processed/package_output/eversmoker/meta.hm3.sumstats.gz" "population" "eversmoker" "mcs"

######################
# clumping analysis
#####################

# run_pgi "${within_family_path}/processed/clumping_analysis/eversmoker/direct/weights/mcs/meta_weights.snpRes.formatted" "direct" "eversmoker" "mcs" "clump"
# run_pgi "${within_family_path}/processed/clumping_analysis/eversmoker/population/weights/mcs/meta_weights.snpRes.formatted" "population" "eversmoker" "mcs" "clump"