#!/usr/bin/env bash
source /var/genetics/proj/within_family/snipar/bin/activate
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/snipar"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
main "bpd" "" "0" "ukb"