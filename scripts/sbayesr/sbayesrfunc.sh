gctb="/disk/genetics/ukb/aokbay/bin/gctb_2.03beta_Linux/gctb"
dirout="/var/genetics/proj/within_family/within_family_project/processed/sbayesr"
within_family_path="/var/genetics/proj/within_family/within_family_project"
refldpanel="/disk/genetics/tools/gctb/ld_reference/ukbEURu_hm3_shrunk_sparse/ukbEURu_mldmlist.txt"

cd $dirout
mkdir -p tmp
mkdir -p logs

function run_pgi(){

    METAFILE=$1
    EFFECT=$2
    PHENONAME=$3
    DATASET=$4

    if [[ $DATASET == "mcs" ]]; then
        pheno="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
        covariates="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
        # bfile="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr${chr}.dose"
        outpath="/var/genetics/data/mcs/private/latest/processed/proj/within_family/pgs/sbayesr"
        pedigree="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/pedigree.txt"

    elif [[ $DATASET == "ukb" ]]; then
        pheno="/disk/genetics/ukb/alextisyoung/phenotypes/processed_traits_noadj.txt"
        covariates="/disk/genetics/ukb/alextisyoung/phenotypes/covariates.txt"
        # bfile="/disk/genetics/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.bgen"
        outpath="/var/genetics/data/ukb/private/v3/processed/proj/within_family/pgs/sbayesr"
        pedigree="/disk/genetics4/ukb/jguan/ukb_analysis/output/parent_imputed/pedigree.txt"
    fi

    mkdir -p ${PHENONAME}/${EFFECT}

    # echo "Formatting summary statistics..."
    # python ${within_family_path}/scripts/sbayesr/format_gwas.py \
    #     "$METAFILE" \
    #     --effecttype "${EFFECT}" \
    #     --outpath "${PHENONAME}/${EFFECT}/meta.sumstats"

    # mkdir -p ${PHENONAME}/${EFFECT}/weights/
    # mkdir -p logs/${EFFECT}

    # # getting weights
    # $gctb --sbayes R \
    # --mldm ${refldpanel} \
    # --exclude-mhc \
    # --seed 123 \
    # --pi 0.95,0.02,0.02,0.01 \
    # --gamma 0.0,0.01,0.1,1 \
    # --gwas-summary ${PHENONAME}/${EFFECT}/meta.sumstats \
    # --chain-length 10000 \
    # --burn-in 2000 \
    # --out-freq 100 \
    # --out ${PHENONAME}/${EFFECT}/weights/meta_weights | tee "logs/${EFFECT}/${PHENONAME}_meta_weights_sbayesr"


    # echo "Formatting sbayesr weights to create scores"
    # python ${within_family_path}/scripts/sbayesr/get_variantid.py \
    #     ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes \
    #     --out ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted

    # # create PGIs
    # mkdir -p $outpath/${PHENONAME}/
    # mkdir -p $outpath/${PHENONAME}/${EFFECT}
 
    for chr in {1..22}
    do
        echo $chr

        if [[ $DATASET == "mcs" ]]; then
            plink200a2 --bfile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr${chr}.dose \
            --chr $chr \
            --score ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted 12 5 8 header center cols=+scoresums \
            --out $outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_${chr}
        elif [[ $DATASET == "ukb" ]]; then
            plink200a2 --bgen /disk/genetics4/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.bgen ref-last \
            --oxford-single-chr $chr \
            --sample /disk/genetics4/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.sample \
            --score ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted 2 5 8 header center cols=+scoresums \
            --out $outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_${chr}
        fi

    done

    python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sumscores.py \
        "$outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_*.sscore" \
        --outprefix "$outpath/${PHENONAME}/${EFFECT}/scoresout.sscore"

    Rscript /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/pgiprediction.R \
        --pgi "$outpath/${PHENONAME}/${EFFECT}/scoresout.sscore" \
        --pheno $pheno \
        --iid_pheno "IID" \
        --pheno_name "$PHENONAME" \
        --covariates $covariates \
        --outprefix "${PHENONAME}/${EFFECT}/pgipred"

    python ${within_family_path}/scripts/sbayesr/parental_pgi_corr.py \
    "$outpath/${PHENONAME}/${EFFECT}/scoresout.sscore" \
    --pedigree ${pedigree} \
    --outprefix "${PHENONAME}/${EFFECT}/"
}
