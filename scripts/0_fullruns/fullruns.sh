#!/usr/bin/bash

act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
ldscenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"
sniparenv="/var/genetics/code/snipar/snipar_venv/bin/activate"
within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}


function main(){

    PHENO=$1

    # bash scripts/qc/runqc_${PHENO}.sh
    # bash scripts/usingpackage/${PHENO}/runmeta.sh
    # bash scripts/sbayesr/${PHENO}_pgi.sh
    # conda deactivate

    # source ${sniparenv}
    bash scripts/fpgs/fpgs_${PHENO}.sh
    
    # ldsc stuff
    # bash scripts/usingpackage/${PHENO}/ldsc_analysis.sh

}

# time main aafb
# time main adhd
# time main agemenarche
# time main asthma
# time main bmi
# time main bpd
# time main bps
# time main cannabis
time main cognition
# time main cpd
# time main depression
# time main depsymp
# time main dpw
time main ea
# time main eczema
# time main eversmoker
# time main extraversion
# time main fev
# time main hayfever
# time main hdl
# time main health
# time main height
# time main hhincome
# time main income
# time main migraine
# time main morningperson
# time main nchildren
# time main nearsight
# time main neuroticism
# time main nonhdl
# time main swb

echo "done with all!"

