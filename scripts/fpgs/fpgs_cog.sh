#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/proj/within_family/within_family_project/processed/fpgs/phenotypes.txt"

source ${within_family_path}/scripts/fpgs/fpgipipeline_function.sh

# base
withinfam_pred ${within_family_path}/processed/sbayesr/cog/direct/weights/meta_weights.snpRes \
    "direct" "cog" \
    "$phenofile" \
    ""
withinfam_pred ${within_family_path}/processed/sbayesr/cog/population/weights/meta_weights.snpRes \
    "population" "cog" \
    "$phenofile" \
    ""

echo "Running fpgi with only covariates"
python $snipar_path/fPGS.py $within_family_path/processed/fpgs/height/covariates \
    --pgs /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt \
    --phenofile ${within_family_path}/processed/fpgs/height/pheno.pheno \
    --pgsreg-r2

# calculate ratio between direct and population effects
python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/cog/direct_coeffratio \
    --pgs ${within_family_path}/processed/fpgs/cog/direct_full.pgs.txt \
    --pgs2 ${within_family_path}/processed/fpgs/cog/direct_proband.pgs.txt \
    --phenofile ${within_family_path}/processed/fpgs/cog/pheno.pheno \
    --pgsreg-r2 \
    --bootstrapfunc d

python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/cog/population_coeffratio \
    --pgs ${within_family_path}/processed/fpgs/cog/population_full.pgs.txt \
    --pgs2 ${within_family_path}/processed/fpgs/cog/population_proband.pgs.txt \
    --phenofile ${within_family_path}/processed/fpgs/cog/pheno.pheno \
    --pgsreg-r2 \
    --bootstrapfunc d


python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/cog/dirpop_ceoffratiodiff \
    --pgsgroup1 ${within_family_path}/processed/fpgs/cog/population_full.pgs.txt,${within_family_path}/processed/fpgs/cog/population_proband.pgs.txt \
    --pgsgroup2 ${within_family_path}/processed/fpgs/cog/direct_full.pgs.txt,${within_family_path}/processed/fpgs/cog/direct_proband.pgs.txt \
    --phenofile ${within_family_path}/processed/fpgs/cog/pheno.pheno \
    --pgsreg-r2 

