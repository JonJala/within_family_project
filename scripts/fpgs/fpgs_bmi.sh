#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
# bedfilepath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/plink/final/mcs"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/bmi_height_sweep7.txt"

function withinfam_pred(){

    WTFILE=$1
    EFFECT=$2
    PHENONAME=$3
    PHENOFILE=$4
    OUTSUFFIX=$5
    
    # format ldpred2 weight files for fpgs
    python ${within_family_path}/scripts/fpgs/format_weights.py \
        $WTFILE \
        --chr Chrom --pos Position --rsid Name --a1 A1 --a2 A2 --beta A1Effect \
        --sep "delim_whitespace" \
        --outfileprefix ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted \
        --sid-as-chrpos  
        
    # generate pheno file
    python $within_family_path/scripts/fpgs/format_pheno.py \
        $PHENOFILE \
        --iid IID --fid FID --phenocol bmi7 \
        --outprefix $within_family_path/processed/fpgs/${PHENONAME}  \
        --subsample /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/filter_extract/eur_samples.txt

    python $snipar_path/fPGS.py \
        $within_family_path/processed/fpgs/${EFFECT}_${PHENONAME} \
        --bedfiles $bedfilepath \
        --impfiles $impfilespath \
        --weights ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
        --scale_pgs

        python ${within_family_path}/scripts/fpgs/attach_covar.py \
        ${within_family_path}/processed/fpgs/${EFFECT}_${PHENONAME}.pgs.txt \
        --covariates /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar.txt \
        --outprefix ${within_family_path}/processed/fpgs/${EFFECT}_${PHENONAME}_full

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        ${within_family_path}/processed/fpgs/${EFFECT}_${PHENONAME}.pgs.txt \
        --keepeffect "proband" \
        --covariates /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar.txt \
        --outprefix ${within_family_path}/processed/fpgs/${EFFECT}_${PHENONAME}_proband


    echo "Rbmiding phenotype: $within_family_path/processed/fpgs/${PHENONAME}.pheno"
    python $snipar_path/fPGS.py $within_family_path/processed/fpgs/${EFFECT}_${PHENONAME}${OUTSUFFIX}_full \
        --pgs ${within_family_path}/processed/fpgs/${EFFECT}_${PHENONAME}_full.pgs.txt \
        --phenofile ${within_family_path}/processed/fpgs/${PHENONAME}.pheno \
        --pgsreg-r2

    python $snipar_path/fPGS.py $within_family_path/processed/fpgs/${EFFECT}_${PHENONAME}${OUTSUFFIX}_proband \
        --pgs ${within_family_path}/processed/fpgs/${EFFECT}_${PHENONAME}_proband.pgs.txt \
        --phenofile ${within_family_path}/processed/fpgs/${PHENONAME}.pheno \
        --pgsreg-r2


}

# # base
# withinfam_pred ${within_family_path}/processed/sbayesr/bmi/direct/weights/meta_weights.snpRes \
#     "direct" "bmi" \
#     "$phenofile" \
#     ""
# withinfam_pred ${within_family_path}/processed/sbayesr/bmi/population/weights/meta_weights.snpRes \
#     "population" "bmi" \
#     "$phenofile" \
#     ""

echo "Running fpgi with only covariates"
# python $snipar_path/fPGS.py $within_family_path/processed/fpgs/bmi_covariates \
#     --pgs /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt \
#     --phenofile ${within_family_path}/processed/fpgs/bmi.pheno \
#     --pgsreg-r2

# calculate ratio between direct and population effects
python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/bmi_direct_coeffratio \
    --pgs ${within_family_path}/processed/fpgs/direct_bmi_full.pgs.txt \
    --pgs2 ${within_family_path}/processed/fpgs/direct_bmi_proband.pgs.txt \
    --phenofile ${within_family_path}/processed/fpgs/bmi.pheno \
    --pgsreg-r2 \
    --bootstrapfunc d

python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/bmi_population_coeffratio \
    --pgs ${within_family_path}/processed/fpgs/population_bmi_full.pgs.txt \
    --pgs2 ${within_family_path}/processed/fpgs/population_bmi_proband.pgs.txt \
    --phenofile ${within_family_path}/processed/fpgs/bmi.pheno \
    --pgsreg-r2 \
    --bootstrapfunc d


python ${within_family_path}/scripts/fpgs/bootstrapest.py \
    ${within_family_path}/processed/fpgs/bmi_dirpop_ceoffratiodiff \
    --pgsgroup1 ${within_family_path}/processed/fpgs/population_bmi_full.pgs.txt,${within_family_path}/processed/fpgs/population_bmi_proband.pgs.txt \
    --pgsgroup2 ${within_family_path}/processed/fpgs/direct_bmi_full.pgs.txt,${within_family_path}/processed/fpgs/direct_bmi_proband.pgs.txt \
    --phenofile ${within_family_path}/processed/fpgs/bmi.pheno \
    --pgsreg-r2 
