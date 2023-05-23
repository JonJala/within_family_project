#!/usr/bin/env bash
source /var/genetics/proj/within_family/snipar_venv/bin/activate

within_family_path="/var/genetics/proj/within_family/within_family_project"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
# main "height" "" "0" "mcs" "prscs"
main "height" "" "0" "ukb" "prscs"

# clumping analysis
# main "height" "" "0" "mcs" "sbayesr" "clump"
