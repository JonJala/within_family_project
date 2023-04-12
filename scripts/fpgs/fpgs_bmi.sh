#!/usr/bin/env bash
source /var/genetics/proj/within_family/snipar_venv/bin/activate

within_family_path="/var/genetics/proj/within_family/within_family_project"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
main "bmi" "" "0" "mcs" "prscs"

# clumping analysis
# main "bmi" "" "0" "mcs" "clump"