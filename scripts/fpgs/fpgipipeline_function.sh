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

        if [[ $PHENONAME == "ea4_meta" ]]; then
            PHENOFILE="/var/genetics/proj/within_family/within_family_project/processed/ea4_meta/UKB_EAfixed_resid.pheno"
        else
            PHENOFILE="/disk/genetics/ukb/alextisyoung/phenotypes/processed_traits_noadj.txt"
        fi

        COVAR="/disk/genetics/ukb/alextisyoung/withinfamily/phen/covariates.txt"
        OUTPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family"
        RAWPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family"
        bedfilepath="/disk/genetics/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/bedfiles/chr_@"
        impfilespath="/disk/genetics/ukb/jguan/ukb_analysis/output/parent_imputed/chr_@"

        mkdir -p $RAWPATH/phen/${PHENONAME}
        mkdir -p $OUTPATH/pgs/fpgs/${PHENONAME}/
    fi

    mkdir -p $within_family_path/processed/fpgs/${PHENONAME}

    # format sbayesr weight files for fpgs
    if [[ $DATASET == "mcs" ]]; then

        if [[ $PHENONAME == "ea4_meta" ]]; then

            mkdir -p ${within_family_path}/processed/sbayesr/${PHENONAME}/${DATASET}

            python ${within_family_path}/scripts/fpgs/format_weights.py \
            $WTFILE \
            --chr Chr --pos BP --rsid SNP --a1 A1 --a2 A2 --beta direct_Beta \
            --sep "delim_whitespace" \
            --outfileprefix ${within_family_path}/processed/sbayesr/${PHENONAME}/${DATASET}/${PHENONAME}_${EFFECT}_fpgs_formatted \
            --sid-as-chrpos  
        else
            python ${within_family_path}/scripts/fpgs/format_weights.py \
                $WTFILE \
                --chr Chrom --pos Position --rsid Name --a1 A1 --a2 A2 --beta A1Effect \
                --sep "delim_whitespace" \
                --outfileprefix ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted \
                --sid-as-chrpos 
        fi

    elif [[ $DATASET == "ukb" ]]; then

        if [[ $PHENONAME == "ea4_meta" ]]; then

            mkdir -p ${within_family_path}/processed/sbayesr/${PHENONAME}/${DATASET}

            python ${within_family_path}/scripts/fpgs/format_weights.py \
                $WTFILE \
                --chr Chr --pos BP --rsid SNP --a1 A1 --a2 A2 --beta direct_Beta \
                --sep "delim_whitespace" \
                --outfileprefix ${within_family_path}/processed/sbayesr/${PHENONAME}/${DATASET}/${PHENONAME}_${EFFECT}_fpgs_formatted
        else
            python ${within_family_path}/scripts/fpgs/format_weights.py \
                $WTFILE \
                --chr Chrom --pos Position --rsid Name --a1 A1 --a2 A2 --beta A1Effect \
                --sep "delim_whitespace" \
                --outfileprefix ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted
        fi
    fi
    
    echo "done formatting weights"
    # generate pheno file

    python $within_family_path/scripts/fpgs/format_pheno.py \
        $PHENOFILE \
        --iid IID --fid FID --phenocol $PHENONAME \
        --outprefix $RAWPATH/phen/${PHENONAME}/pheno  \
        --sep "delim_whitespace" \
        --binary $BINARY

    echo "done formatting pheno"

    # if [[ $PHENONAME == "ea4_meta" ]]; then
    #     pgs.py \
    #         $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX} \
    #         --bed $bedfilepath \
    #         --imp $impfilespath \
    #         --weights ${within_family_path}/processed/sbayesr/${PHENONAME}/${DATASET}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
    #         --scale_pgs | tee $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.log     
    # else
    #     pgs.py \
    #         $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX} \
    #         --bed $bedfilepath \
    #         --imp $impfilespath \
    #         --weights ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
    #         --scale_pgs | tee $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.log 
    # fi 

    echo "done pgs.py"

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --covariates $COVAR \
        --outprefix $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_full

    echo "done attach_covar"

    python ${within_family_path}/scripts/fpgs/attach_covar.py \
        $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}.pgs.txt \
        --keepeffect "proband" \
        --covariates $COVAR \
        --outprefix $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_proband
    
    echo "done attach covar 2"

    if [[ $DATASET == "mcs" ]]; then
        ols="1"
        kin="0"
    elif [[ $DATASET == "ukb" ]]; then
        ols="0"
        kin="1"
    fi

    if [[ $PHENONAME == "ea4_meta" ]]; then
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${DATASET}"
    else
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}"
    fi

    echo "Reading phenotype: $within_family_path/processed/fpgs/${PHENONAME}/phenotype.pheno"
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_full \
        --pgs $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_full.pgs.txt \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "${within_family_path}/processed/fpgs/logs/${PHENONAME}_${EFFECT}${OUTSUFFIX}_full.reg.log"

    python ${within_family_path}/scripts/fpgs/fpgs_reg.py ${fpgs_out}/${EFFECT}${OUTSUFFIX}_proband \
        --pgs $OUTPATH/pgs/fpgs/${PHENONAME}/${EFFECT}${OUTSUFFIX}_proband.pgs.txt \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY \
        --ols $ols \
        --kin $kin | tee "${within_family_path}/processed/fpgs/logs/${PHENONAME}_${EFFECT}${OUTSUFFIX}_proband.reg.log"


}

function main(){

    PHENONAME=$1
    OUTSUFFIX=$2
    BINARY=$3
    DATASET=$4

    direct_weights="${within_family_path}/processed/sbayesr/${PHENONAME}/direct/weights/meta_weights.snpRes"

    if [[ $DATASET == "mcs" ]]; then

        covar_fid='/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar_pedigfid.txt'
        phenofile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/${PHENONAME}/pheno.pheno"
        processed_dir='/var/genetics/data/mcs/private/latest/processed/'
        RAWPATH="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed"

        if [[ $PHENONAME == "ea4_meta" ]]; then
            direct_weights="/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/weights/meta_weights.snpRes.formatted"
        fi

    elif [[ $DATASET == "ukb" ]]; then

        covar_fid='/disk/genetics/ukb/alextisyoung/withinfamily/phen/covar_pedigfid.txt'
        phenofile="/var/genetics/data/ukb/private/latest/processed/proj/within_family/phen/${PHENONAME}/pheno.pheno"
        processed_dir='/var/genetics/data/ukb/private/latest/processed/proj/within_family'
        RAWPATH="/var/genetics/data/ukb/private/latest/processed/proj/within_family"
        if [[ $PHENONAME == "ea4_meta" ]]; then
            direct_weights="/var/genetics/proj/within_family/within_family_project/processed/sbayesr/ea4_meta/direct/weights/meta_noukb_weights.snpRes.formatted"
        fi
        
    fi

    # main prediction
    withinfam_pred $direct_weights \
        "direct" "$PHENONAME" \
        "$OUTSUFFIX" "$BINARY" "$DATASET"
    
    only need direct effects for ea4_meta
    if [[ $PHENONAME != "ea4_meta" ]]; then
        withinfam_pred "${within_family_path}/processed/sbayesr/${PHENONAME}/population/weights/meta_weights.snpRes" \
        "population" "$PHENONAME" \
        "$OUTSUFFIX" "$BINARY" "$DATASET"
    fi

    if [[ $DATASET == "mcs" ]]; then
        ols="1"
        kin="0"
    elif [[ $DATASET == "ukb" ]]; then
        ols="0"
        kin="1"
    fi
    
    if [[ $PHENONAME == "ea4_meta" ]]; then
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}/${DATASET}"
    else
        fpgs_out="$within_family_path/processed/fpgs/${PHENONAME}"
    fi

    echo "Running covariates only regression"
    python ${within_family_path}/scripts/fpgs/fpgs_reg.py  ${fpgs_out}/covariates \
        --pgs ${covar_fid} \
        --phenofile $RAWPATH/phen/${PHENONAME}/pheno.pheno \
        --logistic $BINARY --ols $ols --kin $kin
    
    echo "Estimating direct/pop ratio"

    if [[ $PHENONAME == "ea4_meta" ]]; then
        python ${within_family_path}/scripts/fpgs/bootstrapest.py \
                ${fpgs_out}/dirpop_ceoffratiodiff \
                --pgsgroup1 ${processed_dir}/pgs/fpgs/$PHENONAME/direct_full.pgs.txt,${processed_dir}/pgs/fpgs/${PHENONAME}/direct_proband.pgs.txt \
                --pgsgroup2 ${processed_dir}/pgs/fpgs/$PHENONAME/direct_full.pgs.txt,${processed_dir}/pgs/fpgs/${PHENONAME}/direct_proband.pgs.txt \
                --phenofile $phenofile \
                --pgsreg-r2 
    else
        python ${within_family_path}/scripts/fpgs/bootstrapest.py \
            ${fpgs_out}/dirpop_ceoffratiodiff \
            --pgsgroup1 ${processed_dir}/pgs/fpgs/${PHENONAME}/population_full.pgs.txt,${processed_dir}/pgs/fpgs/${PHENONAME}/population_proband.pgs.txt \
            --pgsgroup2 ${processed_dir}/pgs/fpgs/${PHENONAME}/direct_full.pgs.txt,${processed_dir}/pgs/fpgs/${PHENONAME}/direct_proband.pgs.txt \
            --phenofile $phenofile \
            --pgsreg-r2
    fi
 
}