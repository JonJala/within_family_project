#!/usr/bin/env bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/snipar_simulate"

function withinfam_pred(){

    WTFILE=$1
    EFFECT=$2
    PHENONAME=$3
    OUTSUFFIX=$4
    BINARY=$5
    METHOD=$6

    PHENOFILE="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
    COVAR="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
    OUTPATH="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/${METHOD}"
    RAWPATH="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed"
    bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr@.dose"
    impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr@"

    mkdir -p $RAWPATH/phen/${PHENONAME}
    mkdir -p $OUTPATH
    mkdir -p $within_family_path/processed/fpgs/${PHENONAME}

    outfileprefix="${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}"

    # format weight files for fpgs
    python ${within_family_path}/scripts/fpgs/format_weights.py \
    $WTFILE \
    --chr 0 --pos 2 --rsid 1 --a1 3 --a2 4 --beta 5 \
    --sep "delim_whitespace" \
    --outfileprefix ${outfileprefix}/${PHENONAME}_${EFFECT}_fpgs_formatted \
    --sid-as-chrpos \
    --prscs
    
    # generate pheno file
    python $within_family_path/scripts/fpgs/format_pheno.py \
        $PHENOFILE \
        --iid IID --fid FID --phenocol $PHENONAME \
        --outprefix $RAWPATH/phen/${PHENONAME}/pheno  \
        --sep "delim_whitespace" \
        --binary $BINARY

    PYTHONPATH=${snipar_path} ${snipar_path}/snipar/scripts/pgs.py \
        $OUTPATH/${EFFECT}${OUTSUFFIX} \
        --bed $bedfilepath \
        --imp $impfilespath \
        --weights ${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
        --scale_pgs | tee $OUTPATH/${EFFECT}${OUTSUFFIX}.log 

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        $OUTPATH/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --covariates $COVAR \
        --outprefix $OUTPATH/${EFFECT}${OUTSUFFIX}_full

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        $OUTPATH/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --keepeffect "proband" \
        --covariates $COVAR \
        --outprefix $OUTPATH/${EFFECT}${OUTSUFFIX}_proband

    ols="1"
    kin="0"

    fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}"
    mkdir -p $fpgs_out

    echo "Reading phenotype: $within_family_path/processed/fpgs/${PHENONAME}/phenotype.pheno"
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_full \
        --pgs $OUTPATH/${EFFECT}${OUTSUFFIX}_full.pgs.txt \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "${within_family_path}/processed/fgwas_v2/logs/${PHENONAME}_${CLUMP}_${EFFECT}${OUTSUFFIX}_full.reg.log"

    python ${within_family_path}/scripts/fpgs/fpgs_reg.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_proband \
        --pgs $OUTPATH/${EFFECT}${OUTSUFFIX}_proband.pgs.txt \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "${within_family_path}/processed/fgwas_v2/logs/${PHENONAME}_${CLUMP}_${EFFECT}${OUTSUFFIX}_proband.reg.log"
    
}

function main(){

    PHENONAME=$1
    OUTSUFFIX=$2
    BINARY=$3
    METHOD=$4
    POPULATION=$5

    covar_fid="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt"
    phenofile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/${PHENONAME}/pheno.pheno"
    processed_dir="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/${METHOD}"
    RAWPATH="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed"
    direct_weights="${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/direct/weights/meta_weights.snpRes"
    
    # main prediction -- direct effect pgi
    withinfam_pred $direct_weights \
        "direct" "$PHENONAME" \
        "$OUTSUFFIX" "$BINARY" "$METHOD"

    if [ "$POPULATION" == "dir_pop" ]; then
        # population effect pgi
        population_weights="${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/population/weights/meta_weights.snpRes"
        withinfam_pred $population_weights \
            "population" "$PHENONAME" \
            "$OUTSUFFIX" "$BINARY" "$METHOD"
    fi
    
    ols="1"
    kin="0"
    
    fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}"
    
    echo "Running covariates only regression"
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py  ${fpgs_out}/covariates \
        --pgs ${covar_fid} \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY --ols $ols --kin $kin
 
}