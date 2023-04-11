#!/usr/bin/env bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/var/genetics/code/snipar/SNIPar" # use main branch of snipar 

function withinfam_pred(){

    WTFILE=$1
    EFFECT=$2
    PHENONAME=$3
    OUTSUFFIX=$4
    BINARY=$5
    METHOD=$6
    ANCESTRY=$7

    OUTPATH="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/${METHOD}/${ANCESTRY}"
    RAWPATH="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed"

    if [ $ANCESTRY == "eur" ]; then
        COVAR="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
        PHENOFILE="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes_eur.txt"
    elif [ $ANCESTRY == "sas" ]; then
        COVAR="/var/genetics/data/mcs/private/v1/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_sas.txt"
        PHENOFILE="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes_sas.txt"
    fi

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

    ## use plink to get proband pgis only
    scorefile="${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted"
    outdir="/var/genetics/data/mcs/private/latest/processed/proj/within_family/pgs/fgwas_v2/${ANCESTRY}/${METHOD}/${PHENONAME}/${EFFECT}"
    mkdir -p ${outdir}

    if [ $ANCESTRY == "eur" ]; then

        for chr in {1..22}
        do
            echo $chr      
            plink2 --bfile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr${chr}.dose \
            --chr $chr \
            --score $scorefile 7 4 6 header center cols=+scoresums \
            --out ${outdir}/scores_${chr}
        done

    elif [ $ANCESTRY == "sas" ]; then

        for chr in {1..22}
        do
            echo $chr      
            plink2 --bfile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/SAS/tmp/chr${chr}_mz_removed.dose \
            --chr $chr \
            --score $scorefile 7 4 6 header center cols=+scoresums \
            --out ${outdir}/scores_${chr}
        done

    fi

    # combine scores and standardize
    python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sumscores.py \
    "$outdir/scores_*.sscore" \
    --outprefix "$outdir/scoresout.sscore" \
    --standardize

    header="FID IID proband"
    sed -i "1s/.*/$header/" ${outdir}/scoresout.sscore
    scoresout="${outdir}/scoresout.sscore"

    # attach covariates
    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        ${scoresout} \
        --keepeffect "proband" \
        --covariates $COVAR \
        --outprefix $OUTPATH/${EFFECT}${OUTSUFFIX}_proband

    ols="1"
    kin="0"

    fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}/${ANCESTRY}"
    mkdir -p $fpgs_out

    # run regression
    echo "Reading phenotype: ${pheno_out}/pheno.pheno"
    python ${within_family_path}/scripts/fgwas_v2/fpgs_reg_fgwas.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_proband \
        --pgs $OUTPATH/${EFFECT}${OUTSUFFIX}_proband.pgs.txt \
        --phenofile ${pheno_out}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "${within_family_path}/processed/fgwas_v2/logs/${PHENONAME}_${EFFECT}${OUTSUFFIX}_${ANCESTRY}_proband.reg.log"
    
}

function main(){

    PHENONAME=$1
    OUTSUFFIX=$2
    BINARY=$3
    METHOD=$4
    ANCESTRY=$5
    POPULATION=$6

    processed_dir="/var/genetics/data/mcs/private/latest/processed/pgs/fpgs/${PHENONAME}/${METHOD}/${ANCESTRY}"
    RAWPATH="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed"
    direct_weights="${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/direct/weights/meta_weights.snpRes"
    pheno_out="$RAWPATH/phen/${PHENONAME}/${ANCESTRY}"

    if [ $ANCESTRY = "eur" ]; then
        covar_fid="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt"
    elif [ $ANCESTRY = "sas" ]; then
        covar_fid="/var/genetics/data/mcs/private/v1/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_sas.txt"
    fi

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
    
    ols="1"
    kin="0"

    echo "Running covariates only regression"
    fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}/${ANCESTRY}"
    python ${within_family_path}/scripts/fgwas_v2/fpgs_reg_fgwas.py  ${fpgs_out}/covariates \
        --pgs ${covar_fid} \
        --phenofile ${pheno_out}/pheno.pheno \
        --logistic $BINARY --ols $ols --kin $kin

}