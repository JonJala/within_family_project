#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
withinfam_pred ${within_family_path}/processed/sbayesr/bmi/direct/weights/meta_weights.snpRes \
    "direct" "bmi" \
    "" "0" "mcs"
withinfam_pred ${within_family_path}/processed/sbayesr/bmi/population/weights/meta_weights.snpRes \
    "population" "bmi" \
    "" "0" "mcs"

echo "Running fpgi with only covariates"
python $snipar_path/fPGS.py $within_family_path/processed/fpgs/bmi/covariates \
    --pgs /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt \
    --phenofile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/bmi/pheno.pheno \
    --pgsreg-r2

# calculate ratio between direct and population effects
python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/bmi/dirpop_ceoffratiodiff \
    --pgsgroup1 /var/genetics/data/mcs/private/latest/processed/pgs/fpgs/bmi/population_full.pgs.txt,/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/bmi/population_proband.pgs.txt \
    --pgsgroup2 /var/genetics/data/mcs/private/latest/processed/pgs/fpgs/bmi/direct_full.pgs.txt,/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/bmi/direct_proband.pgs.txt \
    --phenofile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/bmi/pheno.pheno \
    --pgsreg-r2 
