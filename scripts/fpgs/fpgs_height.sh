#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/proj/within_family/within_family_project/processed/fpgs/phenotypes.txt"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
# withinfam_pred ${within_family_path}/processed/sbayesr/height/direct/weights/meta_weights.snpRes \
#     "direct" "height" \
#     "$phenofile" \
#     ""
# withinfam_pred ${within_family_path}/processed/sbayesr/height/population/weights/meta_weights.snpRes \
#     "population" "height" \
#     "$phenofile" \
#     ""

# echo "Running fpgi with only covariates"
# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/height/covariates \
#     --pgs /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt \
#     --phenofile ${within_family_path}/processed/fpgs/height/pheno.pheno \
#     --pgsreg-r2

# # calculate ratio between direct and population effects
# python ${within_family_path}/scripts/fpgs/bootstrapest.py \
#     ${within_family_path}/processed/fpgs/height/direct_coeffratio \
#     --pgs ${within_family_path}/processed/fpgs/height/direct_full.pgs.txt \
#     --pgs2 ${within_family_path}/processed/fpgs/height/direct_proband.pgs.txt \
#     --phenofile ${within_family_path}/processed/fpgs/height/pheno.pheno \
#     --pgsreg-r2 \
#     --bootstrapfunc d

# python ${within_family_path}/scripts/fpgs/bootstrapest.py \
#     ${within_family_path}/processed/fpgs/height/population_coeffratio \
#     --pgs ${within_family_path}/processed/fpgs/height/population_full.pgs.txt \
#     --pgs2 ${within_family_path}/processed/fpgs/height/population_proband.pgs.txt \
#     --phenofile ${within_family_path}/processed/fpgs/height/pheno.pheno \
#     --pgsreg-r2 \
#     --bootstrapfunc d


# python ${within_family_path}/scripts/fpgs/bootstrapest.py \
#     ${within_family_path}/processed/fpgs/height/dirpop_ceoffratiodiff \
#     --pgsgroup1 ${within_family_path}/processed/fpgs/height/population_full.pgs.txt,${within_family_path}/processed/fpgs/height/population_proband.pgs.txt \
#     --pgsgroup2 ${within_family_path}/processed/fpgs/height/direct_full.pgs.txt,${within_family_path}/processed/fpgs/height/direct_proband.pgs.txt \
#     --phenofile ${within_family_path}/processed/fpgs/height/pheno.pheno \
#     --pgsreg-r2 


#### Scratch

Rscript /var/genetics/proj/within_family/within_family_project/scripts/fpgs/attach_ht_dir_pop.R


python $snipar_path/fPGS.py $within_family_path/processed/fpgs/height/dir_pop_full \
    --pgs $within_family_path/processed/fpgs/height/dir_pop.pgs.txt \
    --phenofile ${within_family_path}/processed/fpgs/height/pheno.pheno \
    --pgsreg-r2
