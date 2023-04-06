dirout="/var/genetics/proj/within_family/within_family_project/processed/prscs"
within_family_path="/var/genetics/proj/within_family/within_family_project"
refldpanel="/disk/genetics/tools/prscs/ld_reference/ldblk_ukbb_eur"

cd $dirout

function run_pgi(){

    METAFILE=$1
    EFFECT=$2
    PHENONAME=$3
    DATASET=$4
    CLUMP=$5

    if [[ $DATASET == "mcs" ]]; then

        pheno="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/phenotypes.txt"
        covariates="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/phen/covar.txt"
        outpath="/var/genetics/data/mcs/private/latest/processed/proj/within_family/pgs/prscs"
        pedigree="/var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/imputed_parents/pedigree.txt"

    elif [[ $DATASET == "ukb" ]]; then
        
        pheno="/disk/genetics3/data_dirs/ukb/private/v3/processed/proj/within_family/phen/ukb_phenos.txt"
        covariates="/disk/genetics/ukb/alextisyoung/phenotypes/covariates.txt"
        outpath="/var/genetics/data/ukb/private/v3/processed/proj/within_family/pgs/prscs"
        pedigree="/disk/genetics4/ukb/jguan/ukb_analysis/output/parent_imputed/pedigree.txt"

    fi


    if [[ $PHENONAME == "ea" || $PHENONAME == "cognition" ]]; then
        out="${dirout}/${PHENONAME}/${DATASET}"
    else
        out="${dirout}/${PHENONAME}"
    fi
    mkdir -p ${out}/${EFFECT}/weights

    if [[ -z $CLUMP ]]; then

        echo "Formatting summary statistics..."
        python ${within_family_path}/scripts/prscs/format_gwas.py \
            "$METAFILE" \
            --effecttype "${EFFECT}" \
            --outpath "${out}/${EFFECT}/meta.sumstats" \
            --bimout "${out}/validation.bim"

        # getting weights using prscs
        N_THREADS=1
        export MKL_NUM_THREADS=${N_THREADS}
        export OMP_NUM_THREADS=${N_THREADS}
        export NUMEXPR_NUM_THREADS=${N_THREADS}

        # get median n from sumstats file
        python /var/genetics/proj/within_family/within_family_project/scripts/prscs/get_median_n.py \
            --sumstats ${METAFILE} \
            --effect ${EFFECT} \
            --pheno ${PHENONAME} \
            --outpath ${out}/${EFFECT}
        
        NEFF=$(cat ${out}/${EFFECT}/${EFFECT}_median_n.txt)
        echo "Median N is ${NEFF}"

        mkdir -p ${dirout}/logs/${PHENONAME}/${EFFECT}

        for chr in {1..22}; do
        prscs \
            --ref_dir=${refldpanel} \
            --bim_prefix="${out}/validation" \
            --sst_file="${out}/${EFFECT}/meta.sumstats" \
            --n_gwas=${NEFF} \
            --chrom=${chr} \
            --seed=1 \
            --out_dir=${out}/${EFFECT}/weights/meta_weights 2>&1 | tee "${dirout}/logs/${PHENONAME}/${EFFECT}/chr${chr}_meta_weights_prscs"
        done
        wait

        echo "Formatting PRSCS weights to create scores"

        rm -f ${out}/${EFFECT}/weights/meta_weights.snpRes*
        cat ${out}/${EFFECT}/weights/meta_weights* > ${out}/${EFFECT}/weights/meta_weights.snpRes

        python ${within_family_path}/scripts/prscs/get_variantid.py \
            ${out}/${EFFECT}/weights/meta_weights.snpRes \
            --out ${out}/${EFFECT}/weights/meta_weights.snpRes.formatted

    fi

    scorefile="${out}/${EFFECT}/weights/meta_weights.snpRes.formatted"

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
            
            plink2 --bfile /var/genetics/data/mcs/private/latest/raw/genotyped/NCDS_SFTP_1TB_1/imputed/bgen/tmp/chr${chr}.dose \
            --chr $chr \
            --score $scorefile 7 4 6 header center cols=+scoresums \
            --out $outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_${chr}

        elif [[ $DATASET == "ukb" ]]; then

            plink2 --bgen /disk/genetics4/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.bgen ref-last \
                --oxford-single-chr $chr \
                --sample /disk/genetics4/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.sample \
                --score $scorefile 2 4 6 header center cols=+scoresums \
                --out $outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_${chr}

        fi

    done

    python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/sumscores.py \
        "$outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_*.sscore" \
        --outprefix "$outpath/${PHENONAME}/${EFFECT}/scoresout.sscore"


    outprefix="${out}/${EFFECT}"
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
