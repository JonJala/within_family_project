#!/usr/bin/env bash
source /var/genetics/proj/within_family/snipar_venv/bin/activate

within_family_path="/var/genetics/proj/within_family/within_family_project"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
main "bmi" "" "0" "mcs" "prscs"

# clumping analysis
# main "bmi" "" "0" "mcs" "clump"