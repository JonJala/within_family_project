#!/usr/bin/bash

# run qc for all lifelines phenos
# note: make sure to comment out all the other cohorts' code from each file first!!

/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bmi.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_chol.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_cognition.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_ea.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_es.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_height.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_hdl.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_ldl.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_tgl.sh


