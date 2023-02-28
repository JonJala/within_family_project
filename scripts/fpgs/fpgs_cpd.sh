#!/usr/bin/env bash
source /var/genetics/code/snipar/snipar_venv/bin/activate
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/snipar"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
main "cpd" "" "0" "ukb"