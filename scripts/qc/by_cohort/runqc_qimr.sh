#!/usr/bin/bash

# run qc for all qimr phenos
# note: make sure to comment out all the other cohorts' code from each file first!!

# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_aafb.sh
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bmi.sh
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_cpd.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_depression.sh
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_depsymp.sh
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_dpw.sh
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_ea.sh
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_eversmoker.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_hdl.sh
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_height.sh
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_agemenarche.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_cognition.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_neuroticism.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_nchildren.sh
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_swb.sh

echo "done with all!"