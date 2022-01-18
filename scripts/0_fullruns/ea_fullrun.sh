#!/usr/bin/bash

within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}

bash scripts/qc/runqc_ea.sh
bash scripts/usingpackage/ea/runmeta.sh
bash scripts/sbayesr/ea_pgi.sh
bash scripts/fpgs/fpgs_ea.sh