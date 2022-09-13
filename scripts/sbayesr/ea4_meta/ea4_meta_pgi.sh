#!/usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /disk/genetics4/projects/EA4/code/PGS/7_PGS_SBayesR.sh

within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sbayesrfunc.sh

# ============= Execution ============= #

# direct effect PGIs for MCS and UKB
run_pgi "${within_family_path}/processed/sbayesr/ea4_meta/direct/weights/meta_weights.snpRes.formatted" "direct" "ea4_meta" "mcs"
run_pgi "${within_family_path}/processed/sbayesr/ea4_meta/direct/weights/meta_noukb_weights.snpRes.formatted" "direct" "ea4_meta" "ukb"

# population effect PGIs for MCS and UKB
run_pgi "${within_family_path}/processed/sbayesr/ea4_meta/population/weights/meta_weights.snpRes.formatted" "population" "ea4_meta" "mcs"
run_pgi "${within_family_path}/processed/sbayesr/ea4_meta/population/weights/meta_noukb_weights.snpRes.formatted" "population" "ea4_meta" "ukb"