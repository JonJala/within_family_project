#!/usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /var/genetics/proj/ea4/code/PGS/7_PGS_SBayesR.sh


within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sbayesrfunc.sh

# ============= Execution ============= #
run_pgi "${within_family_path}/processed/package_output/neuroticism/meta.hm3.sumstats.gz" "direct" "neuroticism" "mcs"
run_pgi "${within_family_path}/processed/package_output/neuroticism/meta.hm3.sumstats.gz" "population" "neuroticism" "mcs"

######################
# clumping analysis
#####################

# run_pgi "${within_family_path}/processed/clumping_analysis/neuroticism/direct/weights/mcs/meta_weights.snpRes.formatted" "direct" "neuroticism" "mcs" "clump"
# run_pgi "${within_family_path}/processed/clumping_analysis/neuroticism/population/weights/mcs/meta_weights.snpRes.formatted" "population" "neuroticism" "mcs" "clump"