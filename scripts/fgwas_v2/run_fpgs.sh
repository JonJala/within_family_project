#!/usr/bin/env bash

## --------------------------------------------------------------------------------------------------------
## args:
## PHENONAME=$1. phenotype name
## OUTSUFFIX=$2. suffix for output file (usually blank)
## BINARY=$3. 1 for binary, 0 for continuous outcome phenotype
## METHOD=$4. method used to produce sumstats (unified, robust, sibdiff, young)
## ANCESTRY=$5. ancestry for MCS validation sample. previously we ran for sas and eur, but now just eur.
## POPULATION=$6. "dir_pop" for both direct and population effect pgi, empty otherwise
## --------------------------------------------------------------------------------------------------------

source /var/genetics/proj/within_family/snipar_venv/bin/activate
source /var/genetics/proj/within_family/within_family_project/scripts/fgwas_v2/fpgipipeline_function_fgwas.sh

# unified
main "bmi" "" "0" "unified" "eur" "dir_pop" 
main "height" "" "0" "unified" "eur" "dir_pop" 
main "ea" "" "0" "unified" "eur" "dir_pop" 

## robust
main "bmi" "" "0" "robust" "eur"
main "height" "" "0" "robust" "eur"
main "ea" "" "0" "robust" "eur"

## sibdiff
main "bmi" "" "0" "sibdiff" "eur"
main "height" "" "0" "sibdiff" "eur"
main "ea" "" "0" "sibdiff" "eur"

## young
main "bmi" "" "0" "young" "eur"
main "height" "" "0" "young" "eur"
main "ea" "" "0" "young" "eur"
