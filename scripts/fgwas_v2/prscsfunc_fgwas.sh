within_family_path="/var/genetics/proj/within_family/within_family_project"
refldpanel="/disk/genetics/tools/prscs/ld_reference/ldblk_ukbb_eur"

function run_pgi(){

    FILEPATH=$1
    EFFECT=$2
    PHENONAME=$3
    METHOD=$4
    
    dirout="/var/genetics/proj/within_family/within_family_project/processed/fgwas_v2/${METHOD}"
    pheno="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
    covariates="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
    outpath="/var/genetics/data/mcs/private/latest/processed/proj/within_family/pgs/fgwas_v2/eur/${METHOD}"
    pedigree="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/pedigree.txt"

    mkdir -p ${dirout}
    mkdir -p ${outpath}
    cd $dirout
    mkdir -p ${PHENONAME}/${EFFECT}
    
    echo "Formatting summary statistics..."
    python ${within_family_path}/scripts/fgwas_v2/format_fgwas.py \
        "$FILEPATH" \
        --effecttype "${EFFECT}" \
        --outpath "${dirout}/${PHENONAME}/${EFFECT}/meta.sumstats" \
        --bimout "${dirout}/${PHENONAME}/validation.bim"

    mkdir -p ${PHENONAME}/${EFFECT}/weights/
    mkdir -p logs/${EFFECT}/${PHENONAME}

    # getting weights using prscs
    N_THREADS=1
    export MKL_NUM_THREADS=${N_THREADS}
    export OMP_NUM_THREADS=${N_THREADS}
    export NUMEXPR_NUM_THREADS=${N_THREADS}

    # get median n from sumstats file
    python /var/genetics/proj/within_family/within_family_project/scripts/fgwas_v2/get_median_n_fgwas.py \
        --sumstats ${FILEPATH} \
        --effect ${EFFECT} \
        --pheno ${PHENONAME} \
        --outpath ${dirout}
    
    NEFF=$(cat ${dirout}/${PHENONAME}/${EFFECT}/${EFFECT}_median_n.txt)
    echo "Median N is ${NEFF}"

    for chr in {1..22}; do
        prscs \
            --ref_dir=${refldpanel} \
            --bim_prefix="${PHENONAME}/validation" \
            --sst_file="${PHENONAME}/${EFFECT}/meta.sumstats" \
            --n_gwas=${NEFF} \
            --chrom=${chr} \
            --seed=1 \
            --out_dir=${PHENONAME}/${EFFECT}/weights/meta_weights 2>&1 | tee "${dirout}/logs/${EFFECT}/${PHENONAME}/chr${chr}_meta_weights_prscs"
    done
    wait

    echo "Formatting PRSCS weights to create scores"

    rm -f ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes*
    cat ${PHENONAME}/${EFFECT}/weights/meta_weights* > ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes

    python ${within_family_path}/scripts/prscs/get_variantid.py \
        ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes \
        --out ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted
    
}
