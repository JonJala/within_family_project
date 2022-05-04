#!/usr/bin/bash

act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
ldscenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"
sniparenv="/homes/nber/harij/.conda/envs/sniparenv"
within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}


function main(){

    PHENO=$1

    source ${act} ${sniparenv}
    bash scripts/qc/runqc_${PHENO}.sh
    bash scripts/usingpackage/${PHENO}/runmeta.sh
    bash scripts/sbayesr/${PHENO}_pgi.sh
    bash scripts/fpgs/fpgs_${PHENO}.sh
    
    # ldsc stuff
    source ${act} ${ldscenv}
    bash scripts/usingpackage/${PHENO}/ldsc_analysis.sh

}

time main ea &
time main bmi &
time main height &
time main cognition &
time main depression &
time main eversmoker &