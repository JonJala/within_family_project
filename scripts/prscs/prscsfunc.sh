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
    CLUMP=$5

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
            --median-n \
            --median-n-frac 1 \
            --outpath "${PHENONAME}/${EFFECT}/meta.sumstats"

        mkdir -p ${PHENONAME}/${EFFECT}/weights/
        mkdir -p logs/${EFFECT}

        # create validation.bim file
        # .bim format:
        # A text file with no header line, and one line per variant with the following six fields:
        # Chromosome code (either an integer, or 'X'/'Y'/'XY'/'MT'; '0' indicates unknown) or name
        # Variant identifier
        # Position in morgans or centimorgans (safe to use dummy value of '0')
        # Base-pair coordinate (1-based; limited to 231-2)
        # Allele 1 (corresponding to clear bits in .bed; usually minor)
        # Allele 2 (corresponding to set bits in .bed; usually major)

        awk '{print $1 " " $3 " " "0" " " $2 " " $4 " " $5}' /var/genetics/proj/alz_pgi/alz_pgi_project/processed/proxy/2_qc/QC_.ukb_alz_gwas_sumstats.txt \
            | sed '1d' > /var/genetics/proj/alz_pgi/alz_pgi_project/processed/proxy/3_prscs/validation.bim

        bim_path="/var/genetics/proj/alz_pgi/alz_pgi_project/processed/proxy/3_prscs/validation"

        # getting weights
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

        # getting weights using prscs
        N_THREADS=1
        export MKL_NUM_THREADS=${N_THREADS}
        export OMP_NUM_THREADS=${N_THREADS}
        export NUMEXPR_NUM_THREADS=${N_THREADS}

        for chr in {1..22}; do
        prscs \
            --ref_dir=${refldpanel} \
            --bim_prefix=${bim_path} \
            --sst_file=/var/genetics/proj/alz_pgi/alz_pgi_project/processed/kunkle/4_prscs/kunkle_sumstats_prscs.txt \
            --n_gwas=76299 \
            --chrom=${chr} \
            --seed=1 \
            --out_dir=${PHENONAME}/${EFFECT}/weights/meta_weights
        done
        wait

        echo "Formatting sbayesr weights to create scores"
        python ${within_family_path}/scripts/sbayesr/get_variantid.py \
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
            --score $scorefile 12 5 8 header center cols=+scoresums \
            --out $outpath/${PHENONAME}/${EFFECT}/scores_${DATASET}_${chr}

        elif [[ $DATASET == "ukb" ]]; then

            plink200a2 --bgen /disk/genetics4/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.bgen ref-last \
                --oxford-single-chr $chr \
                --sample /disk/genetics4/ukb/alextisyoung/hapmap3/haplotypes/imputed_phased/chr_${chr}_merged.sample \
                --score $scorefile 2 5 8 header center cols=+scoresums \
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
