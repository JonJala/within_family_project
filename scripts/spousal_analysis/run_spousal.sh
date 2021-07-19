within_family_path="/var/genetics/proj/within_family/within_family_project"
gsbed="/disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3"

for pgi in ${within_family_path}/processed/ldpred2/*.wt.txt
do

echo $pgi
splitbyslash=($(echo $pgi | tr "/" "\n"))
splitbyslashname=${splitbyslash[-1]}
fileoutname_array=($(echo $splitbyslashname | tr "." "\n"))
fileoutname=${fileoutname_array[0]}
echo $fileoutname


    Rscript ${within_family_path}/scripts/ldpred2/ldpred2_wt2pgi.R \
        --bfile $gsbed \
        --wtfile $pgi \
        --wtcolname "ldpred_beta" \
        --outfile ${within_family_path}/processed/spousal_analysis/$fileoutname \
        --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \

    # Rscript ${within_family_path}/scripts/spousal_analysis/run_spousalanalysis.R \
    #     --pgi $pgi \
    #     --pgi_col_name "PGI" \
    #     --pheno "/disk/genetics/sibling_consortium/GS20k/alextisyoung/processed_traits.fam" \
    #     --pheno_col_name "EA" \
    #     --pedigree "/disk/genetics/sibling_consortium/GS20k/alextisyoung/pedigree.txt" \
    #     --outprefix "${within_family_path}/processed/spousal_analysis/${fileoutname}"

done


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