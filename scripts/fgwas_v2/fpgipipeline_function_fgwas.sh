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
    ANCESTRY=$7

    OUTPATH="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/${METHOD}/${ANCESTRY}"
    RAWPATH="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed"
    COVAR="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
    PHENOFILE="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/phenotypes_eur.txt"
    
    mkdir -p $RAWPATH/phen/${PHENONAME}
    mkdir -p $OUTPATH
    mkdir -p $within_family_path/processed/fpgs/${PHENONAME}
    
    # generate pheno file
    pheno_out="$RAWPATH/phen/${PHENONAME}/${ANCESTRY}"
    mkdir -p ${pheno_out}
    python $within_family_path/scripts/fpgs/format_pheno.py \
        $PHENOFILE \
        --iid IID --fid FID --phenocol $PHENONAME \
        --outprefix ${pheno_out}/pheno  \
        --sep "delim_whitespace" \
        --binary $BINARY

    bedfilepath="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr@.dose"
    impfilespath="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr@"

    ## get proband and parental pgis using snipar        
    PYTHONPATH=${snipar_path} ${snipar_path}/snipar/scripts/pgs.py \
        $OUTPATH/${EFFECT}${OUTSUFFIX} \
        --bed $bedfilepath \
        --imp $impfilespath \
        --beta_col "ldpred_beta" \
        --SNP "sid" \
        --A1 "nt1" \
        --A2 "nt2" \
        --weights ${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
        --scale_pgs | tee $OUTPATH/${EFFECT}${OUTSUFFIX}.log 

    scoresout="$OUTPATH/${EFFECT}${OUTSUFFIX}.pgs.txt"
    fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}/${ANCESTRY}"
    mkdir -p $fpgs_out

    ## run fPGI regression
    echo "Run fPGI regression..."
    PYTHONPATH=${snipar_path} ${snipar_path}/snipar/scripts/pgs.py ${fpgs_out}/${EFFECT}${OUTSUFFIX} \
        --pgs ${scoresout} \
        --phenofile ${pheno_out}/pheno.pheno \
        --scale_phen | tee "${within_family_path}/processed/fgwas_v2/logs/${PHENONAME}_${EFFECT}${OUTSUFFIX}_${ANCESTRY}_full.reg.log"

}

function main(){

    PHENONAME=$1
    OUTSUFFIX=$2
    BINARY=$3
    METHOD=$4
    ANCESTRY=$5
    POPULATION=$6

    processed_dir="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/${METHOD}/${ANCESTRY}"
    RAWPATH="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed"
    direct_weights="${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/direct/weights/meta_weights.snpRes"
    pheno_out="$RAWPATH/phen/${PHENONAME}/${ANCESTRY}"
    covar_fid="/var/genetics/data/mcs/private/latest/raw/downloaded/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt"

    # main prediction -- direct effect pgi
    withinfam_pred $direct_weights \
        "direct" "$PHENONAME" \
        "$OUTSUFFIX" "$BINARY" "$METHOD" "$ANCESTRY"

    if [ "$POPULATION" == "dir_pop" ]; then
        # population effect pgi
        population_weights="${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/population/weights/meta_weights.snpRes"
        withinfam_pred $population_weights \
            "population" "$PHENONAME" \
            "$OUTSUFFIX" "$BINARY" "$METHOD" "$ANCESTRY"
    fi
    
}