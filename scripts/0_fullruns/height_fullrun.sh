#!/usr/bin/bash

within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}

bash scripts/qc/runqc_height.sh
bash scripts/usingpackage/height/runmeta.sh
bash scripts/sbayesr/height_pgi.sh
bash scripts/fpgs/fpgs_height.sh