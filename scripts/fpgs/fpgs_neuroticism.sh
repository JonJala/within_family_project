#!/usr/bin/env bash
source /var/genetics/proj/within_family/within_family_project/snipar/bin/activate

within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/within_family_project/snipar"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
main "neuroticism" "" "0" "mcs" 

# clumping analysis
# main "neuroticism" "" "0" "mcs" "clump"