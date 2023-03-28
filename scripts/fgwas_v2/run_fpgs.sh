#!/usr/bin/env bash
source /var/genetics/proj/within_family/snipar_venv/bin/activate

within_family_path="/var/genetics/proj/within_family/within_family_project"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"

source /var/genetics/proj/within_family/within_family_project/scripts/fgwas_v2/fpgipipeline_function_fgwas.sh

## unified
# main "bmi" "" "0" "unified"
# main "height" "" "0" "unified"
# main "ea" "" "0" "unified"

# ## robust
# main "bmi" "" "0" "robust"
# main "height" "" "0" "robust"
# main "ea" "" "0" "robust"

## sibdiff
# main "bmi" "" "0" "sibdiff"
main "height" "" "0" "sibdiff"
# main "ea" "" "0" "sibdiff"

## young
main "bmi" "" "0" "young"
main "height" "" "0" "young"
main "ea" "" "0" "young"
