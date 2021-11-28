#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
# bedfilepath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/plink/final/mcs"
bedfilepath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr~.dose"
impfilespath="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/imputed_parents/chr~"

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
        --iid Benjamin_ID --phenocol Z_EA \
        --sep "\t" \
        --outprefix $within_family_path/processed/fpgs/${PHENONAME}  \
        --subsample /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/filter_extract/eur_samples.txt

    python $snipar_path/fPGS.py \
        $within_family_path/processed/fpgs/${EFFECT}_${PHENONAME} \
        --bedfiles $bedfilepath \
        --impfiles $impfilespath \
        --weights ${within_family_path}/processed/sbayesr/${PHENONAME}/${PHENONAME}_${EFFECT}_fpgs_formatted.txt \
        --scale_pgs

    python $snipar_path/fPGS.py $within_family_path/processed/fpgs/${EFFECT}_${PHENONAME}${OUTSUFFIX} \
        --pgs $within_family_path/processed/fpgs/${EFFECT}_${PHENONAME}.pgs.txt \
        --phenofile $within_family_path/processed/fpgs/${PHENONAME}.pheno \
        --pgsreg-r2


}

# base
# withinfam_pred ${within_family_path}/processed/sbayesr/ea/direct/weights/meta_weights.snpRes \
#     "direct" "ea" \
#     "/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_mean.phen" \
#     ""
# withinfam_pred ${within_family_path}/processed/sbayesr/ea/population/weights/meta_weights.snpRes \
#     "population" "ea" \
#     "/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_mean.phen" \
#     ""

# english phenotype
withinfam_pred ${within_family_path}/processed/sbayesr/ea/direct/weights/meta_weights.snpRes \
    "direct" "ea" \
    "/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_eng.phen" \
    "_english"
withinfam_pred ${within_family_path}/processed/sbayesr/ea/population/weights/meta_weights.snpRes \
    "population" "ea" \
    "/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_eng.phen" \
    "_english"

# maths phenotype
withinfam_pred ${within_family_path}/processed/sbayesr/ea/direct/weights/meta_weights.snpRes \
    "direct" "ea" \
    "/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_math.phen" \
    "_maths"
withinfam_pred ${within_family_path}/processed/sbayesr/ea/population/weights/meta_weights.snpRes \
    "population" "ea" \
    "/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_math.phen" \
    "_maths"

