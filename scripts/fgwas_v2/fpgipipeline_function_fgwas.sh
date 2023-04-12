#!/usr/bin/env bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
# snipar_path="/var/genetics/code/snipar/SNIPar" # use main branch of snipar 
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

    if [ $ANCESTRY == "eur" ]; then

        bedfilepath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr@.dose"
        impfilespath="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr@"

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

        # attach covariates to full pgs file
        python ${within_family_path}/scripts/fpgs/attach_covar.py \
            $OUTPATH/${EFFECT}${OUTSUFFIX}.pgs.txt \
            --covariates $COVAR \
            --outprefix $OUTPATH/${EFFECT}${OUTSUFFIX}_full

        scoresout="$OUTPATH/${EFFECT}${OUTSUFFIX}.pgs.txt"

    elif [ $ANCESTRY == "sas" ]; then

        ## use plink to get proband pgis only
        scorefile="${within_family_path}/processed/fgwas_v2/${METHOD}/${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted"
        outdir="/var/genetics/data/mcs/private/latest/processed/proj/within_family/pgs/fgwas_v2/${ANCESTRY}/${METHOD}/${PHENONAME}/${EFFECT}"
        mkdir -p ${outdir}

        for chr in {1..22}
        do
            echo $chr      
            plink2 --bfile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/SAS/tmp/chr${chr}_mz_removed.dose \
            --chr $chr \
            --score $scorefile 7 4 6 header center cols=+scoresums \
            --out ${outdir}/scores_${chr}
        done

        # combine scores and standardize
        python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sumscores.py \
        "$outdir/scores_*.sscore" \
        --outprefix "$outdir/scoresout.sscore" \
        --standardize

        header="FID IID proband"
        sed -i "1s/.*/$header/" ${outdir}/scoresout.sscore
        scoresout="${outdir}/scoresout.sscore"

    fi

    # attach covariates to proband pgis
    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        ${scoresout} \
        --keepeffect "proband" \
        --covariates $COVAR \
        --outprefix $OUTPATH/${EFFECT}${OUTSUFFIX}_proband

    ols="1"
    kin="0"

    fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${METHOD}/${ANCESTRY}"
    mkdir -p $fpgs_out

    if [ $ANCESTRY == "eur" ]; then
        ## run full fPGI regression if EUR
        echo "Run full fPGI regression..."
        PYTHONPATH=${snipar_path} ${snipar_path}/snipar/scripts/pgs.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_full \
            --pgs $OUTPATH/${EFFECT}${OUTSUFFIX}.pgs.txt \
            --phenofile ${pheno_out}/pheno.pheno \
            --scale_phen | tee "${within_family_path}/processed/fgwas_v2/logs/${PHENONAME}_${EFFECT}${OUTSUFFIX}_${ANCESTRY}_full.reg.log"
    elif [ $ANCESTRY == "sas" ]; then
        ## run proband PGI regression only otherwise
        python ${within_family_path}/scripts/fgwas_v2/fpgs_reg_fgwas.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_proband \
            --pgs $OUTPATH/${EFFECT}${OUTSUFFIX}_proband.pgs.txt \
            --phenofile ${pheno_out}/pheno.pheno \
            --logistic $BINARY \
            --ols $ols \
            --kin $kin | tee "${within_family_path}/processed/fgwas_v2/logs/${PHENONAME}_${EFFECT}${OUTSUFFIX}_${ANCESTRY}_proband.reg.log"
    fi    

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
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py  ${fpgs_out}/covariates \
        --pgs ${covar_fid} \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --sniparpath ${snipar_path} \
        --logistic $BINARY --ols $ols --kin $kin \
        --covariates_only

}