#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
withinfam_pred ${within_family_path}/processed/sbayesr/eversmoker/direct/weights/meta_weights.snpRes \
    "direct" "eversmoker" \
    "" "1" "mcs"
withinfam_pred ${within_family_path}/processed/sbayesr/eversmoker/population/weights/meta_weights.snpRes \
    "population" "eversmoker" \
    "" "1" "mcs"

echo "Running covariates only regression"
python $snipar_path/fPGS.py $within_family_path/processed/fpgs/eversmoker/covariates \
    --pgs /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt \
    --phenofile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/eversmoker/pheno.pheno \
    --pgsreg-r2


python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/eversmoker/dirpop_ceoffratiodiff \
    --pgsgroup1 /var/genetics/data/mcs/private/latest/processed/pgs/fpgs/eversmoker/population_full.pgs.txt,/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/eversmoker/population_proband.pgs.txt \
    --pgsgroup2 /var/genetics/data/mcs/private/latest/processed/pgs/fpgs/eversmoker/direct_full.pgs.txt,/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/eversmoker/direct_proband.pgs.txt \
    --phenofile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/eversmoker/pheno.pheno \
    --pgsreg-r2 

