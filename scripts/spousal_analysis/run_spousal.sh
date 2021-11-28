within_family_path="/var/genetics/proj/within_family/within_family_project"
gsbed="/disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3"


for pheno in ea
do

echo ${pheno}

    for effect in direct
    do

    echo $effect

    Rscript ${within_family_path}/scripts/spousal_analysis/run_spousalanalysis.R \
        --pgi ${within_family_path}/processed/sbayesr/${pheno}/${effect}/scoresout.sscore \
        --pgi_col_name "SCORE" \
        --pheno "/var/genetics/proj/within_family/within_family_project/processed/fpgs/ea.pheno" \
        --pheno_col_name "Z_EA" \
        --pedigree "/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/imputed_parents/pedigree.txt" \
        --outprefix "${within_family_path}/processed/spousal_analysis/${pheno}_${effect}" \
        --subsample "/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/filter_extract/eur_samples.txt"

    done

done


# for pgi in ${within_family_path}/processed/sbayesr/*/*/weights/meta_weights.snpRes
# do

# echo $pgi
# splitbyslash=($(echo $pgi | tr "/" "\n"))
# splitbyslashname=${splitbyslash[-1]}
# fileoutname_array=($(echo $splitbyslashname | tr "." "\n"))
# fileoutname=${fileoutname_array[0]}
# echo $fileoutname


#     Rscript ${within_family_path}/scripts/ldpred2/ldpred2_wt2pgi.R \
#         --bfile $gsbed \
#         --wtfile $pgi \
#         --wtcolname "ldpred_beta" \
#         --outfile ${within_family_path}/processed/spousal_analysis/$fileoutname \
#         --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \

#     Rscript ${within_family_path}/scripts/spousal_analysis/run_spousalanalysis.R \
#         --pgi $pgi \
#         --pgi_col_name "PGI" \
#         --pheno "/disk/genetics/sibling_consortium/GS20k/alextisyoung/processed_traits.fam" \
#         --pheno_col_name "EA" \
#         --pedigree "/disk/genetics/sibling_consortium/GS20k/alextisyoung/pedigree.txt" \
#         --outprefix "${within_family_path}/processed/spousal_analysis/${fileoutname}"

# done


# Rscript ${within_family_path}/scripts/spousal_analysis/run_spousalanalysis.R \
#     --pgi $within_family_path/processed/fpgs/pop_ea.pgs.txt \
#     --pgi_col_name "proband" \
#     --pheno "/disk/genetics/sibling_consortium/GS20k/alextisyoung/processed_traits.fam" \
#     --pheno_col_name "EA" \
#     --pedigree "/disk/genetics/sibling_consortium/GS20k/alextisyoung/pedigree.txt" \
#     --outprefix "${within_family_path}/processed/spousal_analysis/pop_ea"

# EA4 ref

# Rscript ${within_family_path}/scripts/spousal_analysis/run_spousalanalysis.R \
#     --pgi /var/genetics/proj/within_family/within_family_project/processed/ldpred2/ea4_ref.pgi.txt \
#     --pgi_col_name "PGI" \
#     --pheno "/disk/genetics/sibling_consortium/GS20k/alextisyoung/processed_traits.fam" \
#     --pheno_col_name "EA" \
#     --pedigree "/disk/genetics/sibling_consortium/GS20k/alextisyoung/pedigree.txt" \
#     --outprefix "${within_family_path}/processed/spousal_analysis/ea4_ref"