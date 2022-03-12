#!/usr/bin/bash

act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
ldscenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"
sniparenv="/homes/nber/harij/.conda/envs/sniparenv"
within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}


function main(){

    source ${act} ${sniparenv}
    # bash scripts/qc/runqc_height.sh
    # bash scripts/usingpackage/height/runmeta.sh
    bash scripts/sbayesr/height_pgi.sh
    bash scripts/fpgs/fpgs_height.sh
    
    # ldsc stuff
    source ${act} ${ldscev}
    bash scripts/usingpackage/height/ldsc_analysis.sh

    # compiling results
    source ${act} ${sniparenv}
    python scripts/usingpackage/compile_results.py
}


time main