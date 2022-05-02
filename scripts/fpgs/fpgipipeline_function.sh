#!/usr/bin/env bash


within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/within_family_project/snipar"

function withinfam_pred(){

    WTFILE=$1
    EFFECT=$2
    PHENONAME=$3
    OUTSUFFIX=$4
    BINARY=$5
    DATASET=$6

    if [[ $DATASET == "mcs" ]]; then
        PHENOFILE="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
        COVAR="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
        OUTPATH="/var/genetics/data/mcs/private/latest/processed/"
        RAWPATH="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed"
        bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr@.dose"
        impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr@"

        mkdir -p $RAWPATH/phen/${PHENONAME}
        mkdir -p $OUTPATH/pgs/fpgs/${PHENONAME}/
        
    elif [[ $DATASET == "ukb" ]]; then
        PHENOFILE="/disk/genetics/ukb/alextisyoung/phenotypes/processed_traits_noadj.txt"
        # COVAR="/disk/genetics/ukb/alextisyoung/phenotypes/covariates.txt"
        COVAR="/disk/genetics/ukb/alextisyoung/withinfamily/phen/covariates.txt"
        OUTPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family"
        RAWPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family"
        bedfilepath="/disk/genetics/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/bedfiles/chr_@"
        impfilespath="/disk/genetics/ukb/jguan/ukb_analysis/output/parent_imputed/chr_@"

        mkdir -p $RAWPATH/phen/${PHENONAME}
        mkdir -p $OUTPATH/pgs/fpgs/${PHENONAME}/
    fi

    mkdir -p $within_family_path/processed/fpgs/${PHENONAME}

    # format ldpred2 weight files for fpgs
    if [[ $DATASET == "mcs" ]]; then

        python ${within_family_path}/scripts/fpgs/format_weights.py \
            $WTFILE \
            --chr Chrom --pos Position --rsid Name --a1 A1 --a2 A2 --beta A1Effect \
            --sep "delim_whitespace" \
            --outfileprefix ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted \
            --sid-as-chrpos  

    elif [[ $DATASET == "ukb" ]]; then

        python ${within_family_path}/scripts/fpgs/format_weights.py \
            $WTFILE \
            --chr Chrom --pos Position --rsid Name --a1 A1 --a2 A2 --beta A1Effect \
            --sep "delim_whitespace" \
            --outfileprefix ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted
    fi
        
    # generate pheno file
    python $within_family_path/scripts/fpgs/format_pheno.py \
        $PHENOFILE \
        --iid IID --fid FID --phenocol $PHENONAME \
        --outprefix $RAWPATH/phen/${PHENONAME}/pheno  \
        --binary $BINARY


    pgs.py \
        $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX} \
        --bed $bedfilepath \
        --imp $impfilespath \
        --weights ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
        --scale_pgs | tee $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.log 

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --covariates $COVAR \
        --outprefix $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_full

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --keepeffect "proband" \
        --covariates $COVAR \
        --outprefix $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_proband


    if [[ $DATASET == "mcs" ]]; then
        ols="1"
        kin="0"
    elif [[ $DATASET == "ukb" ]]; then
        ols="0"
        kin="1"
    fi
    echo "Reading phenotype: $within_family_path/processed/fpgs/${PHENONAME}/phenotype.pheno"
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py $within_family_path/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_full \
        --pgs $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_full.pgs.txt \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "$within_family_path/processed/fpgs/logs/${PHENONAME}_${EFFECT}${OUTSUFFIX}_full.reg.log"

    python ${within_family_path}/scripts/fpgs/fpgs_reg.py $within_family_path/processed/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_proband \
        --pgs $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_proband.pgs.txt \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "$within_family_path/processed/fpgs/logs/${PHENONAME}_${EFFECT}${OUTSUFFIX}_proband.reg.log"


}

function main(){

    PHENONAME=$1
    OUTSUFFIX=$2
    BINARY=$3
    DATASET=$4


    if [[ $DATASET == "mcs" ]]; then

        covar_fid='/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt'
        phenofile='/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/' 
        processed_dir='/var/genetics/data/mcs/private/latest/processed/'

    elif [[ $DATASET == "ukb" ]]; then

        covar_fid='/disk/genetics/ukb/alextisyoung/withinfamily/phen/covar_pedigfid.txt'
        phenofile='/disk/genetics/ukb/alextisyoung/withinfamily/phen/'
        processed_dir='/disk/genetics/ukb/alextisyoung/withinfamily/'

    fi


    # main prediction
    withinfam_pred ${within_family_path}/processed/sbayesr/${PHENONAME}/direct/weights/meta_weights.snpRes \
        "direct" "$PHENONAME" \
        "$OUTSUFFIX" "$BINARY" "$DATASET"
    
    withinfam_pred ${within_family_path}/processed/sbayesr/${PHENONAME}/population/weights/meta_weights.snpRes \
        "population" "$PHENONAME" \
        "$OUTSUFFIX" "$BINARY" "$DATASET"

    if [[ $DATASET == "mcs" ]]; then
        ols="1"
        kin="0"
    elif [[ $DATASET == "ukb" ]]; then
        ols="0"
        kin="1"
    fi
    echo "Running covariates only regression"
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py  $within_family_path/processed/fpgs/$PHENONAME/covariates \
        --pgs ${covar_fid} \
        --phenofile $phenofile/$PHENONAME/pheno.pheno \
        --logistic $BINARY --ols $ols --kin $kin
    
    echo "Estimating direct/pop ratio"
    python ${within_family_path}/scripts/fpgs/bootstrapest.py \
        ${within_family_path}/processed/fpgs/$PHENONAME/dirpop_ceoffratiodiff \
        --pgsgroup1 ${processed_dir}/pgs/fpgs/$PHENONAME/population_full.pgs.txt,${processed_dir}/pgs/fpgs/$PHENONAME/population_proband.pgs.txt \
        --pgsgroup2 ${processed_dir}pgs/fpgs/$PHENONAME/direct_full.pgs.txt,${processed_dir}/pgs/fpgs/$PHENONAME/direct_proband.pgs.txt \
        --phenofile ${phenofile}/$PHENONAME/pheno.pheno \
        --pgsreg-r2 
}