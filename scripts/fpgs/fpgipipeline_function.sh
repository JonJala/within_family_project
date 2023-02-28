#!/usr/bin/env bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/code/snipar/SNIPar"

function withinfam_pred(){

    WTFILE=$1
    EFFECT=$2
    PHENONAME=$3
    OUTSUFFIX=$4
    BINARY=$5
    DATASET=$6
    METHOD=$7
    CLUMP=$8

    if [[ $DATASET == "mcs" ]]; then

        PHENOFILE="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
        COVAR="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
        OUTPATH="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/"
        RAWPATH="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed"
        bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr@.dose"
        impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr@"
        
    elif [[ $DATASET == "ukb" ]]; then
        
        PHENOFILE="/var/genetics/data/ukb/private/v3/processed/proj/within_family/phen/ukb_phenos.txt"
        COVAR="/disk/genetics/ukb/alextisyoung/withinfamily/phen/covariates.txt"
        OUTPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/${PHENONAME}/"
        RAWPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family"
        bedfilepath="/disk/genetics/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/bedfiles/chr_@"
        impfilespath="/disk/genetics/ukb/jguan/ukb_analysis/output/parent_imputed/chr_@"

    fi

    mkdir -p $RAWPATH/phen/${PHENONAME}
    mkdir -p $OUTPATH
    mkdir -p $within_family_path/processed/fpgs/${PHENONAME}

    if [[ ! -z $CLUMP ]]; then
        mkdir -p ${within_family_path}/processed/${METHOD}/${PHENONAME}/clumping_analysis/${DATASET}
        outfileprefix="${within_family_path}/processed/${METHOD}/${PHENONAME}/clumping_analysis/${DATASET}"
    else
        outfileprefix="${within_family_path}/processed/${METHOD}/${PHENONAME}"
    fi

    # format weight files for fpgs
    if [[ $METHOD == "sbayesr" ]]; then
        if [[ $DATASET == "mcs" ]]; then
            python ${within_family_path}/scripts/fpgs/format_weights.py \
            $WTFILE \
            --chr Chrom --pos Position --rsid Name --a1 A1 --a2 A2 --beta A1Effect \
            --sep "delim_whitespace" \
            --outfileprefix ${outfileprefix}/${PHENONAME}_${EFFECT}_fpgs_formatted \
            --sid-as-chrpos 
        elif [[ $DATASET == "ukb" ]]; then
            python ${within_family_path}/scripts/fpgs/format_weights.py \
            $WTFILE \
            --chr Chrom --pos Position --rsid Name --a1 A1 --a2 A2 --beta A1Effect \
            --sep "delim_whitespace" \
            --outfileprefix ${outfileprefix}/${PHENONAME}_${EFFECT}_fpgs_formatted
        fi
    elif [[ $METHOD == "prscs" ]]; then
        if [[ $DATASET == "mcs" ]]; then
            python ${within_family_path}/scripts/fpgs/format_weights.py \
            $WTFILE \
            --chr 0 --pos 2 --rsid 1 --a1 3 --a2 4 --beta 5 \
            --sep "delim_whitespace" \
            --outfileprefix ${outfileprefix}/${PHENONAME}_${EFFECT}_fpgs_formatted \
            --sid-as-chrpos \
            --prscs
        elif [[ $DATASET == "ukb" ]]; then
            python ${within_family_path}/scripts/fpgs/format_weights.py \
            $WTFILE \
            --chr 0 --pos 2 --rsid 1 --a1 3 --a2 4 --beta 5 \
            --sep "delim_whitespace" \
            --outfileprefix ${outfileprefix}/${PHENONAME}_${EFFECT}_fpgs_formatted \
            --prscs
        fi
    fi
    
    # generate pheno file
    python $within_family_path/scripts/fpgs/format_pheno.py \
        $PHENOFILE \
        --iid IID --fid FID --phenocol $PHENONAME \
        --outprefix $RAWPATH/phen/${PHENONAME}/pheno  \
        --sep "delim_whitespace" \
        --binary $BINARY

    if [[ $METHOD == "prscs" ]]; then
        mkdir -p "${OUTPATH}/prscs"
        OUTPATH+="prscs" 
    fi

    if [[ ! -z $CLUMP ]]; then
        mkdir -p "${OUTPATH}/clumping_analysis"
        OUTPATH+="clumping_analysis" 
        python ${snipar_path}/snipar/scripts/pgs.py \
            $OUTPATH/${EFFECT}${OUTSUFFIX} \
            --bed $bedfilepath \
            --imp $impfilespath \
            --weights ${within_family_path}/processed/${METHOD}/${PHENONAME}/clumping_analysis/${DATASET}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
            --scale_pgs | tee $OUTPATH/${EFFECT}${OUTSUFFIX}.log
    else
        python ${snipar_path}/snipar/scripts/pgs.py \
            $OUTPATH/${EFFECT}${OUTSUFFIX} \
            --bed $bedfilepath \
            --imp $impfilespath \
            --weights ${within_family_path}/processed/${METHOD}/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
            --scale_pgs | tee $OUTPATH/${EFFECT}${OUTSUFFIX}.log 
    fi 

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        $OUTPATH/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --covariates $COVAR \
        --outprefix $OUTPATH/${EFFECT}${OUTSUFFIX}_full

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        $OUTPATH/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --keepeffect "proband" \
        --covariates $COVAR \
        --outprefix $OUTPATH/${EFFECT}${OUTSUFFIX}_proband


    if [[ $DATASET == "mcs" ]]; then
        ols="1"
        kin="0"
    elif [[ $DATASET == "ukb" ]]; then
        ols="0"
        kin="1"
    fi

    if [[ ! -z $CLUMP ]]; then
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/clumping_analysis/${DATASET}"
        mkdir -p $fpgs_out
    elif [[ $METHOD == "prscs" ]]; then
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}"
        mkdir -p $fpgs_out
    else
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}"
    fi

    echo "Reading phenotype: $within_family_path/processed/fpgs/${PHENONAME}/phenotype.pheno"
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_full \
        --pgs $OUTPATH/${EFFECT}${OUTSUFFIX}_full.pgs.txt \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "${within_family_path}/processed/fpgs/logs/${PHENONAME}_${CLUMP}_${EFFECT}${OUTSUFFIX}_full.reg.log"

    python ${within_family_path}/scripts/fpgs/fpgs_reg.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_proband \
        --pgs $OUTPATH/${EFFECT}${OUTSUFFIX}_proband.pgs.txt \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "${within_family_path}/processed/fpgs/logs/${PHENONAME}_${CLUMP}_${EFFECT}${OUTSUFFIX}_proband.reg.log"
    
}

function main(){

    PHENONAME=$1
    OUTSUFFIX=$2
    BINARY=$3
    DATASET=$4
    METHOD=$5
    CLUMP=$6

    if [[ $DATASET == "mcs" ]]; then

        covar_fid="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt"
        phenofile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/${PHENONAME}/pheno.pheno"
        processed_dir="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/"
        RAWPATH="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed"

    elif [[ $DATASET == "ukb" ]]; then

        covar_fid="/disk/genetics/ukb/alextisyoung/withinfamily/phen/covar_pedigfid.txt"
        phenofile="/var/genetics/data/ukb/private/latest/processed/proj/within_family/phen/${PHENONAME}/pheno.pheno"
        processed_dir="/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/${PHENONAME}/"
        RAWPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family"
        
    fi

    if [[ -z $CLUMP ]]; then

        # for the regular pipeline, this is where the weights outputted by sbayesr are saved
        direct_weights="${within_family_path}/processed/${METHOD}/${PHENONAME}/direct/weights/meta_weights.snpRes"
        population_weights="${within_family_path}/processed/${METHOD}/${PHENONAME}/population/weights/meta_weights.snpRes"
    
    elif [[ ! -z $CLUMP ]]; then
    
        echo "Running clumping analysis"
        direct_weights="${within_family_path}/processed/clumping_analysis/${PHENONAME}/direct/weights/${DATASET}/meta_weights.snpRes.formatted"
        population_weights="${within_family_path}/processed/clumping_analysis/${PHENONAME}/population/weights/${DATASET}/meta_weights.snpRes.formatted"
        processed_dir+="clumping_analysis"
    
    fi

    if [[ $METHOD == "prscs" ]]; then
        processed_dir+="prscs"
    fi

    # main prediction
    withinfam_pred $direct_weights \
        "direct" "$PHENONAME" \
        "$OUTSUFFIX" "$BINARY" "$DATASET" "$METHOD" "$CLUMP"
    
    withinfam_pred $population_weights \
    "population" "$PHENONAME" \
    "$OUTSUFFIX" "$BINARY" "$DATASET" "$METHOD" "$CLUMP"


    if [[ $DATASET == "mcs" ]]; then
        ols="1"
        kin="0"
    elif [[ $DATASET == "ukb" ]]; then
        ols="0"
        kin="1"
    fi
    
    if [[ ! -z $CLUMP ]]; then
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/clumping_analysis/${DATASET}"
    elif [[ $METHOD == "prscs" ]]; then
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}"
    else
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}"
    fi

    echo "Running covariates only regression"
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py  ${fpgs_out}/covariates \
        --pgs ${covar_fid} \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY --ols $ols --kin $kin
    
    echo "Estimating direct/pop ratio"
    python ${within_family_path}/scripts/fpgs/bootstrapest.py \
        ${fpgs_out}/dirpop_ceoffratiodiff \
        --pgsgroup1 ${processed_dir}/population_full.pgs.txt,${processed_dir}/population_proband.pgs.txt \
        --pgsgroup2 ${processed_dir}/direct_full.pgs.txt,${processed_dir}/direct_proband.pgs.txt \
        --phenofile $phenofile \
        --pgsreg-r2
 
}