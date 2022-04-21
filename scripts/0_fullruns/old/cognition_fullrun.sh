#!/usr/bin/bash

act="/disk/genetics/pub/python_env/anaconda2/bin/activate"
ldscenv="/disk/genetics/pub/python_env/anaconda2/envs/ldsc"
sniparenv="/homes/nber/harij/.conda/envs/sniparenv"
within_family_directory="/var/genetics/proj/within_family/within_family_project"
cd ${within_family_directory}

source scripts/0_fullruns/fullrun_function.sh

time main cognition