#!/usr/bin/bash

# run qc for all fhs phenos
# note: make sure to comment out all the other cohorts' code from each file first!!

/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_health.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bps.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_height.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_hdl.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_dpw.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_depsymp.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bpd.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_cpd.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bmi.sh