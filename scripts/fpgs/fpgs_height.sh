#!/usr/bin/env bash
source /var/genetics/proj/within_family/within_family_project/snipar/bin/activate

within_family_path="/var/genetics/proj/within_family/within_family_project"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
# main "height" "" "0" "mcs"

# clumping analysis
main "height" "" "0" "mcs" "clump"
