#!/usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /disk/genetics4/projects/EA4/code/PGS/7_PGS_SBayesR.sh


within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sbayesrfunc.sh

# ============= Execution ============= #
# run_pgi "${within_family_path}/processed/package_output/cognition/meta.hm3.sumstats.gz" "direct" "cognition" "mcs"
# run_pgi "${within_family_path}/processed/package_output/cognition/meta.hm3.sumstats.gz" "population" "cognition" "mcs"

run_pgi "${within_family_path}/processed/package_output/cognition/meta_noukb.sumstats.gz" "direct" "cognition" "ukb"
run_pgi "${within_family_path}/processed/package_output/cognition/meta_noukb.sumstats.gz" "population" "cognition" "ukb"

######################
# clumping analysis
#####################

# run_pgi "${within_family_path}/processed/clumping_analysis/cognition/direct/weights/mcs/meta_weights.snpRes.formatted" "direct" "cognition" "mcs" "clump"
# run_pgi "${within_family_path}/processed/clumping_analysis/cognition/population/weights/mcs/meta_weights.snpRes.formatted" "population" "cognition" "mcs" "clump"