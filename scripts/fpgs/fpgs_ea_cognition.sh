#!/usr/bin/env bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/proj/within_family/snipar_simulate"
sniparenv="/var/genetics/proj/within_family/snipar_venv/bin/activate"

source ${sniparenv}

## function to run fpgs regression
function run_fpgs_regression(){
    
    PHENONAME=$1
    VALIDATION=$2
    BINARY=$3
    METHOD=$4
    DATASET=$5
    OUTSUFFIX=$6

    if [[ $DATASET == "mcs" ]]; then
        PHENOFILE="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
        RAWPATH="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed"
        OUTPATH="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/${METHOD}"
    elif [[ $DATASET == "ukb" ]]; then  
        PHENOFILE="/var/genetics/data/ukb/private/v3/processed/proj/within_family/phen/ukb_phenos.txt"
        RAWPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family"
        OUTPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/${PHENONAME}/${METHOD}"
    fi

    pheno_out="$RAWPATH/phen/${PHENONAME}/${VALIDATION}"
    mkdir -p $pheno_out

    ## generate pheno file
    python $within_family_path/scripts/fpgs/format_pheno.py \
        $PHENOFILE \
        --iid IID --fid FID --phenocol $VALIDATION \
        --outprefix ${pheno_out}/pheno  \
        --sep "delim_whitespace" \
        --binary $BINARY

    fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}/${DATASET}/${VALIDATION}"
    mkdir -p $fpgs_out

    for EFFECT in "direct" "population"
    do
        ## run regression
        echo "Running fPGS regression..."
        python ${within_family_path}/scripts/fpgs/fpgs_reg.py ${fpgs_out}/${EFFECT}${OUTSUFFIX} \
            --pgs $OUTPATH/${EFFECT}${OUTSUFFIX}_full.pgs.txt \
            --phenofile ${pheno_out}/pheno.pheno \
            --phenoname $PHENONAME \
            --dataset $DATASET \
            --sniparpath ${snipar_path} \
            --binary $BINARY 2>&1 | tee "${within_family_path}/processed/fpgs/logs/${PHENONAME}_${DATASET}_${EFFECT}${OUTSUFFIX}.reg.log"
    done

}


## function to get bootstrap estimates of coeff ratio
function bootstrap_coeffratio_ests(){
    
    PHENONAME=$1
    VALIDATION=$2
    METHOD=$3
    DATASET=$4

    if [[ $DATASET == "mcs" ]]; then
        phenofile="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/${PHENONAME}/pheno.pheno"
        processed_dir="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/${METHOD}"
    elif [[ $DATASET == "ukb" ]]; then
        phenofile="/var/genetics/data/ukb/private/latest/processed/proj/within_family/phen/${PHENONAME}/pheno.pheno"
        processed_dir="/var/genetics/data/ukb/private/latest/processed/proj/within_family/pgs/fpgs/${PHENONAME}/${METHOD}"
    fi

    bootstrap_out="${within_family_path}/processed/fpgs/${PHENONAME}/${METHOD}/${DATASET}/${VALIDATION}/dirpop_coeffratiodiff"

    python ${within_family_path}/scripts/fpgs/bootstrapest.py \
        ${bootstrap_out} \
        --pgsgroup1 ${processed_dir}/population_full.pgs.txt,${processed_dir}/population_proband.pgs.txt \
        --pgsgroup2 ${processed_dir}/direct_full.pgs.txt,${processed_dir}/direct_proband.pgs.txt \
        --phenofile ${phenofile} \
        --pgsreg-r2

}

function get_ntc_ratios(){

    PHENONAME=$1
    VALIDATION=$2
    METHOD=$3
    DATASET=$4

    ## get ntc coeffs, ratios, and SEs
    Rscript ${within_family_path}/scripts/fpgs/get_ntc_ratios.R \
        --filepath "${within_family_path}/processed/fpgs/${PHENONAME}/${METHOD}/${DATASET}/${VALIDATION}"

}



## mcs outcomes
for pheno in "ea" "cognition"
do
    for validation in "ea" "cognition" "cogverb"
    do
        run_fpgs_regression "${pheno}" "${validation}" "0" "prscs" "mcs" ""
        get_ntc_ratios "${pheno}" "${validation}" "prscs" "mcs"
    done
done

## ukb outcomes
for pheno in "ea" "cognition"
do
    for validation in "ea" "cognition"
    do
        run_fpgs_regression "${pheno}" "${validation}" "0" "prscs" "ukb" ""
        get_ntc_ratios "${pheno}" "${validation}" "prscs" "ukb"
    done
done
