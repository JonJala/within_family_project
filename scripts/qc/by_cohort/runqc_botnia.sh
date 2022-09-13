#!/usr/bin/bash

# run qc for all botnia phenos
# note: make sure to comment out all the other cohorts' code from each file first!!

/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_ea.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_hdl.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_nonhdl.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_height.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bmi.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bpd.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bps.sh