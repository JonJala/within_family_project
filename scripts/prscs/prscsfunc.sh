dirout="/var/genetics/proj/within_family/within_family_project/processed/prscs"
within_family_path="/var/genetics/proj/within_family/within_family_project"
refldpanel="/disk/genetics/tools/prscs/ld_reference/ldblk_ukbb_eur"

cd $dirout
mkdir -p tmp
mkdir -p logs

function run_pgi(){

    METAFILE=$1
    EFFECT=$2
    PHENONAME=$3
    DATASET=$4
    NEFF=$5
    CLUMP=$6

    if [[ $DATASET == "mcs" ]]; then

        pheno="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
        covariates="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
        outpath="/var/genetics/data/mcs/private/latest/processed/proj/within_family/pgs/prscs"
        pedigree="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/pedigree.txt"

    elif [[ $DATASET == "ukb" ]]; then
        
        if [[ $PHENONAME == "ea" ]] && [[ ! -z $CLUMP ]]; then
            pheno="/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/ea/UKB_EAfixed_resid.pheno"
        elif [[ $PHENONAME == "asthma" || $PHENONAME == "hdl" ||  $PHENONAME == "nonhdl" || $PHENONAME == "bps" || $PHENONAME == "bpd" || $PHENONAME == "migraine" || $PHENONAME == "nearsight" || $PHENONAME == "income" || $PHENONAME == "hayfever" ]]; then
            pheno="/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/UKB_health_income_std_WF.pheno"
        else
            pheno="/disk/genetics/ukb/alextisyoung/phenotypes/processed_traits_noadj.txt"
        fi

        covariates="/disk/genetics/ukb/alextisyoung/phenotypes/covariates.txt"
        outpath="/var/genetics/data/ukb/private/v3/processed/proj/within_family/pgs/prscs"
        pedigree="/disk/genetics4/ukb/jguan/ukb_analysis/output/parent_imputed/pedigree.txt"

    fi

    mkdir -p ${PHENONAME}/${EFFECT}

    if [[ -z $CLUMP ]]; then

        echo "Formatting summary statistics..."
        python ${within_family_path}/scripts/prscs/format_gwas.py \
            "$METAFILE" \
            --effecttype "${EFFECT}" \
            --outpath "${PHENONAME}/${EFFECT}/meta.sumstats" \
            --bimout "${PHENONAME}/validation.bim"

        mkdir -p ${PHENONAME}/${EFFECT}/weights/
        mkdir -p logs/${EFFECT}

        # getting weights using prscs
        N_THREADS=1
        export MKL_NUM_THREADS=${N_THREADS}
        export OMP_NUM_THREADS=${N_THREADS}
        export NUMEXPR_NUM_THREADS=${N_THREADS}

        for chr in {1..22}; do
        prscs \
            --ref_dir=${refldpanel} \
            --bim_prefix="${PHENONAME}/validation" \
            --sst_file="${PHENONAME}/${EFFECT}/meta.sumstats" \
            --n_gwas=${NEFF} \
            --chrom=${chr} \
            --seed=1 \
            --out_dir=${PHENONAME}/${EFFECT}/weights/meta_weights
        done
        wait

        echo "Formatting PRSCS weights to create scores"

        rm -f ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes*
        cat ${PHENONAME}/${EFFECT}/weights/meta_weights* > ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes

        python ${within_family_path}/scripts/prscs/get_variantid.py \
            ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes \
            --out ${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted

    fi

    scorefile="${PHENONAME}/${EFFECT}/weights/meta_weights.snpRes.formatted"

    if [[ ! -z $CLUMP ]]; then
        outpath+="/clumping_analysis"
        scorefile="/var/genetics/proj/within_family/within_family_project/processed/clumping_analysis/${PHENONAME}/${EFFECT}/weights/${DATASET}/meta_weights.snpRes.formatted"
    fi

    # create PGIs
    mkdir -p $outpath/${PHENONAME}/
    mkdir -p $outpath/${PHENONAME}/${EFFECT}
 
    for chr in {1..22}
    do
        echo $chr
        
        if [[ $DATASET == "mcs" ]]; then
            
            plink200a2 --bfile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr${chr}.dose \
            --chr $chr \
            --score $scorefile 7 4 6 header center cols=+scoresums \
            --out $outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_${chr}

        elif [[ $DATASET == "ukb" ]]; then

            plink200a2 --bgen /disk/genetics4/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.bgen ref-last \
                --oxford-single-chr $chr \
                --sample /disk/genetics4/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.sample \
                --score $scorefile 2 4 6 header center cols=+scoresums \
                --out $outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_${chr}

        fi

    done

    python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sumscores.py \
        "$outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_*.sscore" \
        --outprefix "$outpath/${PHENONAME}/${EFFECT}/scoresout.sscore"


    outprefix="${PHENONAME}/${EFFECT}"
    if [[ ! -z $CLUMP ]]; then
        mkdir -p ${PHENONAME}/clumping_analysis/${EFFECT}/${DATASET}
        outprefix="${PHENONAME}/clumping_analysis/${EFFECT}/${DATASET}"
    fi

    Rscript /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/pgiprediction.R \
        --pgi "$outpath/${PHENONAME}/${EFFECT}/scoresout.sscore" \
        --pheno $pheno \
        --iid_pheno "IID" \
        --pheno_name "$PHENONAME" \
        --covariates $covariates \
        --outprefix "${outprefix}/pgipred"

    python ${within_family_path}/scripts/sbayesr/parental_pgi_corr.py \
    "$outpath/${PHENONAME}/${EFFECT}/scoresout.sscore" \
    --pedigree ${pedigree} \
    --outprefix "${outprefix}/"
}
