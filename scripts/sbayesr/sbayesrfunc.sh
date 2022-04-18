gctb="/disk/genetics/ukb/aokbay/bin/gctb_2.03beta_Linux/gctb"
dirout="/var/genetics/proj/within_family/within_family_project/processed/sbayesr"
within_family_path="/var/genetics/proj/within_family/within_family_project"
pheno="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
covariates="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
refldpanel="/disk/genetics/tools/gctb/ld_reference/ukbEURu_hm3_shrunk_sparse/ukbEURu_mldmlist.txt"

cd $dirout
mkdir -p tmp
mkdir -p logs

function run_pgi(){

    METAFILE=$1
    EFFECT=$2
    PHENONAME=$3

    mkdir -p ${PHENONAME}/${EFFECT}

    echo "Formatting summary statistics..."
    python ${within_family_path}/scripts/sbayesr/format_gwas.py \
        "$METAFILE" \
        --effecttype "${EFFECT}" \
        --outpath "${PHENONAME}/${EFFECT}/meta.sumstats"

    mkdir -p ${PHENONAME}/${EFFECT}/weights/
    mkdir -p logs/${EFFECT}

    # getting weights
    $gctb --sbayes R \
    --mldm ${refldpanel} \
    --exclude-mhc \
    --seed 123 \
    --pi 0.95,0.02,0.02,0.01 \
    --gamma 0.0,0.01,0.1,1 \
    --gwas-summary ${PHENONAME}/${EFFECT}/meta.sumstats \
    --chain-length 10000 \
    --burn-in 2000 \
    --out-freq 100 \
    --out ${PHENONAME}/${EFFECT}/weights/meta_weights | tee "logs/${EFFECT}/${PHENONAME}_meta_weights_sbayesr"


    echo "Formatting sbayesr weights to create scores"
    python ${within_family_path}/scripts/sbayesr/get_variantid.py \
        ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes \
        --out ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted

    # create PGIs
    mkdir -p /var/genetics/data/mcs/private/latest/processed/pgs/sbayesr/${PHENONAME}/
    mkdir -p /var/genetics/data/mcs/private/latest/processed/pgs/sbayesr/${PHENONAME}/${EFFECT}
 
    for chr in {1..22}
    do
        echo $chr
        plink200a2 --bfile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr${chr}.dose  \
        --chr $chr \
        --score ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted 12 5 8 header center cols=+scoresums \
        --out /var/genetics/data/mcs/private/latest/processed/pgs/sbayesr/${PHENONAME}/${EFFECT}/scores_mcs_${chr}
    done

    python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sumscores.py \
        "/var/genetics/data/mcs/private/latest/processed/pgs/sbayesr/${PHENONAME}/${EFFECT}/scores_mcs_*.sscore" \
        --outprefix "/var/genetics/data/mcs/private/latest/processed/pgs/sbayesr/${PHENONAME}/${EFFECT}/scoresout.sscore"

    Rscript /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/pgiprediction.R \
        --pgi "/var/genetics/data/mcs/private/latest/processed/pgs/sbayesr/${PHENONAME}/${EFFECT}/scoresout.sscore" \
        --pheno $pheno \
        --iid_pheno "IID" \
        --pheno_name "$PHENONAME" \
        --covariates $covariates \
        --outprefix "${PHENONAME}/${EFFECT}/pgipred"

    python ${within_family_path}/scripts/sbayesr/parental_pgi_corr.py \
    "/var/genetics/data/mcs/private/latest/processed/pgs/sbayesr/${PHENONAME}/${EFFECT}/scoresout.sscore" \
    --outprefix "${PHENONAME}/${EFFECT}/"
}
