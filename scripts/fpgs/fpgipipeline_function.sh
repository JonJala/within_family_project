#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"
phenofile="/var/genetics/proj/within_family/within_family_project/processed/fpgs/phenotypes.txt"

function withinfam_pred(){

    WTFILE=$1
    EFFECT=$2
    PHENONAME=$3
    PHENOFILE=$4
    OUTSUFFIX=$5

    mkdir -p $within_family_path/processed/fpgs/${PHENONAME} 

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
        --iid IID --fid FID --phenocol $PHENONAME \
        --outprefix $within_family_path/processed/fpgs/${PHENONAME}/pheno  \
        --subsample /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/filter_extract/eur_samples.txt

    # python $snipar_path/fPGS.py \
    #     $within_family_path/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX} \
    #     --bedfiles $bedfilepath \
    #     --impfiles $impfilespath \
    #     --weights ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
    #     --scale_pgs

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        ${within_family_path}/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --covariates /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar.txt \
        --outprefix ${within_family_path}/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_full

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        ${within_family_path}/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --keepeffect "proband" \
        --covariates /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar.txt \
        --outprefix ${within_family_path}/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_proband


    echo "Reading phenotype: $within_family_path/processed/fpgs/${PHENONAME}/phenotype.pheno"
    python $snipar_path/fPGS.py $within_family_path/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_full \
        --pgs ${within_family_path}/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_full.pgs.txt \
        --phenofile ${within_family_path}/processed/fpgs/${PHENONAME}/pheno.pheno \
        --pgsreg-r2

    python $snipar_path/fPGS.py $within_family_path/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_proband \
        --pgs ${within_family_path}/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_proband.pgs.txt \
        --phenofile ${within_family_path}/processed/fpgs/${PHENONAME}/pheno.pheno \
        --pgsreg-r2


}

