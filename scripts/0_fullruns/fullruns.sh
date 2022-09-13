#!/usr/bin/bash

act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
ldscenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"
sniparenv="/var/genetics/proj/within_family/within_family_project/snipar/bin/activate"
within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}


function main(){

    PHENO=$1

    bash scripts/qc/runqc_${PHENO}.sh
    bash scripts/usingpackage/${PHENO}/runmeta.sh
    bash scripts/sbayesr/${PHENO}_pgi.sh
    conda deactivate

    source ${sniparenv}
    bash scripts/fpgs/fpgs_${PHENO}.sh
    
    # ldsc stuff
    bash scripts/usingpackage/${PHENO}/ldsc_analysis.sh

}


time main asthma &
time main bpd &
time main bps &
time main cpd &
time main dpw &
time main eczema &
wait

time main health &
time main income &
time main nchildren &
time main rhinitis &
time main swb &
wait

time main fev &
time main hayfever &
time main migraine &
time main nonhdl &
wait

time main hdl &
time main neuroticism &
time main aafb &
time main adhd &
time main agemenarche &
wait

time main ea &
time main bmi &
time main height &
time main cognition &
time main depression &
time main eversmoker &
wait

