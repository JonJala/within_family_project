#!/usr/bin/env bash
source /var/genetics/proj/within_family/within_family_project/snipar/bin/activate

within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

main "ea" "" "0" "mcs" "sbayesr"


# clumping analysis
# main "ea" "" "0" "mcs" "clump"
# main "ea" "" "0" "ukb" "clump"


# ea4
# withinfam_pred ${within_family_path}/processed/sbayesr/ea/ea4/weights/meta_weights.snpRes \
#     "ea4" "ea" \
#     "$phenofile" \
#     ""

# python ${within_family_path}/scripts/fpgs/bootstrapest.py \
#     ${within_family_path}/processed/fpgs/ea_ea4/direct_coeffratio \
#     --pgs ${within_family_path}/processed/fpgs/ea/ea4_full.pgs.txt \
#     --pgs2 ${within_family_path}/processed/fpgs/ea/ea4_proband.pgs.txt \
#     --phenofile ${within_family_path}/processed/fpgs/ea/pheno.pheno \
#     --pgsreg-r2 \
#     --bootstrapfunc d


# meta + ea4
# withinfam_pred ${within_family_path}/processed/sbayesr/ea_ea4/direct/weights/meta_weights.snpRes \
#     "direct" "ea" \
#     "$phenofile" \
#     "_withea4"
# withinfam_pred ${within_family_path}/processed/sbayesr/ea_ea4/population/weights/meta_weights.snpRes \
#     "population" "ea" \
#     "$phenofile" \
#     "_withea4"


# # calculate ratio between direct and population effects
# python ${within_family_path}/scripts/fpgs/bootstrapest.py \
#     ${within_family_path}/processed/fpgs/ea/direct_coeffratio_withea4 \
#     --pgs ${within_family_path}/processed/fpgs/ea/direct_withea4_full.pgs.txt \
#     --pgs2 ${within_family_path}/processed/fpgs/ea/direct_withea4_proband.pgs.txt \
#     --phenofile ${within_family_path}/processed/fpgs/ea/pheno.pheno \
#     --pgsreg-r2 \
#     --bootstrapfunc d

# python ${within_family_path}/scripts/fpgs/bootstrapest.py \
#     ${within_family_path}/processed/fpgs/ea/population_coeffratio_withea4 \
#     --pgs ${within_family_path}/processed/fpgs/ea/population_withea4_full.pgs.txt \
#     --pgs2 ${within_family_path}/processed/fpgs/ea/population_withea4_proband.pgs.txt \
#     --phenofile ${within_family_path}/processed/fpgs/ea/pheno.pheno \
#     --pgsreg-r2 \
#     --bootstrapfunc d


# python ${within_family_path}/scripts/fpgs/bootstrapest.py \
#     ${within_family_path}/processed/fpgs/ea/dirpop_ceoffratiodiff_withea4 \
#     --pgsgroup1 ${within_family_path}/processed/fpgs/ea/population_withea4_full.pgs.txt,${within_family_path}/processed/fpgs/ea/population_withea4_proband.pgs.txt \
#     --pgsgroup2 ${within_family_path}/processed/fpgs/ea/direct_withea4_full.pgs.txt,${within_family_path}/processed/fpgs/ea/direct_withea4_proband.pgs.txt \
#     --phenofile ${within_family_path}/processed/fpgs/ea/pheno.pheno \
#     --pgsreg-r2 
