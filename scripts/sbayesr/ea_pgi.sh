#!usr/bin/bash

# Reference sbayesr code borrowed from Aysu
# Original code /disk/genetics4/projects/EA4/code/PGS/7_PGS_SBayesR.sh

gctb="/disk/genetics/ukb/aokbay/bin/gctb_2.03beta_Linux/gctb"
dirout="/var/genetics/proj/within_family/within_family_project/processed/sbayesr"
within_family_path="/var/genetics/proj/within_family/within_family_project"
pheno="/var/genetics/data/mcs/private/v1/processed/phen/EA/MCS_EA_zscore_mean.phen"
covariates="/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
refldpanel="/disk/genetics/tools/gctb/ld_reference/ukbEURu_hm3_shrunk_sparse/ukbEURu_mldmlist.txt"
# refldpanel="/disk/genetics/tools/gctb/ld_reference/UKB_LD_matrices_2.8M_variants/ukb_50k_bigset_2.8M/ukb50k_2.8M_shrunk_sparse.mldmlist"

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
        --median-n \
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
    for chr in {1..22}
    do
        echo $chr
        plink200a2 --bfile /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr${chr}.dose  \
        --chr $chr \
        --score ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted 12 5 8 header center cols=+scoresums \
        --out ${PHENONAME}/${EFFECT}/scores_mcs_${chr}
    done

    python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sumscores.py \
        "${PHENONAME}/${EFFECT}/scores_mcs_*.sscore" \
        --outprefix "${PHENONAME}/${EFFECT}/scoresout.sscore"

    Rscript /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/pgiprediction.R \
        --pgi "${PHENONAME}/${EFFECT}/scoresout.sscore" \
        --pheno $pheno \
        --iid_pheno "Benjamin_ID" \
        --pheno_name "Z_EA" \
        --covariates $covariates \
        --outprefix "${PHENONAME}/${EFFECT}/pgipred"

    python ${within_family_path}/scripts/sbayesr/parental_pgi_corr.py \
    "${PHENONAME}/${EFFECT}/scoresout.sscore" \
    --outprefix "${PHENONAME}/${EFFECT}/"
}

# ============= Execution ============= #
run_pgi "${within_family_path}/processed/package_output/ea/meta.sumstats" "direct" "ea"
run_pgi "${within_family_path}/processed/package_output/ea/meta.sumstats" "population" "ea"

run_pgi "${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.sumstats" "direct" "ea_ea4"
run_pgi "${within_family_path}/processed/package_output/ea/ea_meta_analysis_ea4.sumstats" "population" "ea_ea4"

######################
# EA4
#####################
# getting weights
# mkdir logs/ea4/ -p
# mkdir ea/ea4/weights/ -p

# $gctb --sbayes R \
#     --mldm /disk/genetics/tools/gctb/ld_reference/ukbEURu_hm3_shrunk_sparse/ukbEURu_mldmlist.txt \
#     --exclude-mhc \
#     --seed 123 \
#     --pi 0.95,0.02,0.02,0.01 \
#     --gamma 0.0,0.01,0.1,1 \
#     --gwas-summary /var/genetics/proj/within_family/within_family_project/processed/ea4/ea4_full_forsabyesr.sumstats \
#     --chain-length 10000 \
#     --burn-in 2000 \
#     --out-freq 100 \
#     --out ea/ea4/weights/meta_weights | tee "logs/ea4/ea4_meta_weights_sbayesr"


# echo "Formatting sbayesr weights to create scores"
# python ${within_family_path}/scripts/sbayesr/get_variantid.py \
#     ea/ea4/weights/meta_weights.snpRes \
#     --out ea/ea4/weights/meta_weights.snpRes.formatted

# # create PGIs
# for chr in {1..22}
# do
#     echo $chr
#     plink200a2 --bfile /var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr${chr}.dose  \
#     --chr $chr \
#     --score ea/ea4/weights/meta_weights.snpRes.formatted 12 5 8 header center cols=+scoresums \
#     --out ea/ea4/scores_mcs_${chr}
# done

# python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sumscores.py \
#     "ea/ea4/scores_mcs_*.sscore" \
#     --outprefix "ea/ea4/scoresout.sscore"

# Rscript /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/pgiprediction.R \
#     --pgi "ea/ea4/scoresout.sscore" \
#     --pheno $pheno \
#     --iid_pheno "Benjamin_ID" \
#     --pheno_name "Z_EA" \
#     --covariates $covariates \
#     --outprefix "ea/ea4/pgipred"


python ${within_family_path}/scripts/sbayesr/parental_pgi_corr.py \
"ea/ea4/scoresout.sscore" \
--outprefix "ea/ea4/"