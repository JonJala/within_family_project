#!/usr/bin/bash

# run qc for all ukb phenos
# note: make sure to comment out all the other cohorts' code from each file first!!

/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_height.sh &
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_neuroticism.sh &
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_hdl.sh & # use updated data from aysu
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_fev.sh &
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_swb.sh &
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_agemenarche.sh &
wait

/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_eversmoker.sh &
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_ea.sh & # running on ipsych
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_cognition.sh & # running on ipsych
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_bmi.sh &
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_aafb.sh & # running on ipsych
wait

/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_cpd.sh &
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_dpw.sh &
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_cannabis.sh & # not working
# /var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_hhincome.sh & # running on ipsych
/var/genetics/proj/within_family/within_family_project/scripts/qc/runqc_health.sh &
# to add dep symp when avail
wait
