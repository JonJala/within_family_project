#!/usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /disk/genetics4/projects/EA4/code/PGS/7_PGS_SBayesR.sh

within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sbayesrfunc.sh

# ============= Execution ============= #
run_pgi "${within_family_path}/processed/package_output/hdl/meta_noukb.sumstats.gz" "direct" "hdl" "ukb"
run_pgi "${within_family_path}/processed/package_output/hdl/meta_noukb.sumstats.gz" "population" "hdl" "ukb"

######################
# clumping analysis
#####################

# run_pgi "${within_family_path}/processed/clumping_analysis/hdl/direct/weights/ukb/meta_weights.snpRes.formatted" "direct" "hdl" "ukb" "clump"
# run_pgi "${within_family_path}/processed/clumping_analysis/hdl/population/weights/ukb/meta_weights.snpRes.formatted" "population" "hdl" "ukb" "clump"