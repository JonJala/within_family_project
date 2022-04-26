#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/within_family_project/snipar"
# bedfilepath="/var/genetics/data/ukb/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
# impfilespath="/var/genetics/data/ukb/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
# phenofile="/var/genetics/data/ukb/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh
source /var/genetics/proj/within_family/within_family_project/bin/activate

# base
withinfam_pred ${within_family_path}/processed/sbayesr/hdl/direct/weights/meta_weights.snpRes \
    "direct" "hdl" \
    "" "0" "ukb"
withinfam_pred ${within_family_path}/processed/sbayesr/hdl/population/weights/meta_weights.snpRes \
    "population" "hdl" \
    "" "0" "ukb"

echo "Running fpgi with only covariates"
python $snipar_path/fPGS.py $within_family_path/processed/fpgs/hdl/covariates \
    --pgs /var/genetics/dsata/ukb/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt \
    --phenofile /var/genetics/data/ukb/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/hdl/pheno.pheno \
    --pgsreg-r2

# calculate ratio between direct and population effects
python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/hdl/dirpop_ceoffratiodiff \
    --pgsgroup1 /var/genetics/data/ukb/private/latest/processed/pgs/fpgs/hdl/population_full.pgs.txt,/var/genetics/data/ukb/private/latest/processed/pgs/fpgs/hdl/population_proband.pgs.txt \
    --pgsgroup2 /var/genetics/data/ukb/private/latest/processed/pgs/fpgs/hdl/direct_full.pgs.txt,/var/genetics/data/ukb/private/latest/processed/pgs/fpgs/hdl/direct_proband.pgs.txt \
    --phenofile /var/genetics/data/ukb/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/hdl/pheno.pheno \
    --pgsreg-r2 
