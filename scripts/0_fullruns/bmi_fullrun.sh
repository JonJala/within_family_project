#!/usr/bin/bash

within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}

bash scripts/qc/runqc_bmi.sh
bash scripts/usingpackage/bmi/runmeta.sh
bash scripts/sbayesr/bmi_pgi.sh
bash scripts/fpgs/fpgs_bmi.sh