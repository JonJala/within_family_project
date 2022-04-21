
#!usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /disk/genetics4/projects/EA4/code/PGS/7_PGS_SBayesR.sh


within_family_path="/var/genetics/proj/within_family/within_family_project"

source /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sbayesrfunc.sh

# ============= Execution ============= #
run_pgi "${within_family_path}/processed/package_output/depression/meta.sumstats.gz" "direct" "depression" "mcs"
run_pgi "${within_family_path}/processed/package_output/depression/meta.sumstats.gz" "population" "depression" "mcs"