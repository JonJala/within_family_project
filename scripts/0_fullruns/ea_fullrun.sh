#!/usr/bin/bash

act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
ldscenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"
sniparenv="/homes/nber/harij/.conda/envs/sniparenv"
within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}

function main(){

    source ${act} ${sniparenv}
    # bash scripts/qc/runqc_ea.sh
    # bash scripts/usingpackage/ea/runmeta.sh
    bash scripts/sbayesr/ea_pgi.sh
    bash scripts/fpgs/fpgs_ea.sh
    
    # ldsc stuff
    source ${act} ${ldscev}
    bash scripts/usingpackage/ea/ldsc_analysis.sh
}


time main