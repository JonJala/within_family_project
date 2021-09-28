#!/usr/bin/bash

within_family_path="/var/genetics/proj/within_family/within_family_project"
ssgac_path="/homes/nber/harij/ssgac"
gsbed="/disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3"

# make ld matrix
# python $ssgac_path/polygenic_prediction/ld_sbayesr.py \
#     --bfile $within_family_path/processed/sbayesr/referenceld/gs/tmp/gsbed_tmp \
#     --out-path "/var/genetics/proj/within_family/within_family_project/processed/sbayesr/referenceld/gs" \
#     --make-sparse-ldm \
#     --chunksize 10000 \
#     --concurrent-processes 18 \
#     --name "generationscotland_hrc_hm3"

# python $ssgac_path/polygenic_prediction/pgi_sbayesr.py \
#     --pfile-path $gsbed \
#     --sumstats $within_family_path/processed/package_output/ea/ea_meta_analysis_ea4.csv \
#     --snp SNP --effect-freq freq --beta dir_Beta --se dir_SE --p dir_pval --N dir_N \
#     --effect-allele A1 --other-allele A2 \
#     --validation-set $within_family_path/processed/sbayesr/gs_validation.fam \
#     --out-path $within_family_path/processed/sbayesr/meta_with_ea4/ \
#     --ld-reference $within_family_path/processed/sbayesr/referenceld/gs/generationscotland_hrc_hm3.mldmlist

# python $ssgac_path/polygenic_prediction/pgi_sbayesr.py \
#     --pfile-path $gsbed \
#     --sumstats $within_family_path/processed/package_output/ea/ea_meta_analysis_amat.csv \
#     --snp SNP --effect-freq freq --beta dir_Beta --se dir_SE --p dir_pval --N dir_N \
#     --effect-allele A1 --other-allele A2 \
#     --validation-set $within_family_path/processed/sbayesr/gs_validation.fam \
#     --out-path $within_family_path/processed/sbayesr/meta_no_ea4/ \
#     --ld-reference $within_family_path/processed/sbayesr/referenceld/gs/generationscotland_hrc_hm3.mldmlist

# The above code usually fails with the plink stuff so we'll run that manually
# First format it so that we have chr:bp for the variant id
python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/get_variantid.py \
     $within_family_path/processed/sbayesr/meta_with_ea4/estimates.posterior \
     --out $within_family_path/processed/sbayesr/meta_with_ea4/estimates.posterior.formatted

python /var/genetics/proj/within_family/within_family_project/scripts/sbayesr/get_variantid.py \
     $within_family_path/processed/sbayesr/meta_no_ea4/estimates.posterior \
     --out $within_family_path/processed/sbayesr/meta_no_ea4/estimates.posterior.formatted

# get PGIs
plink2 --bfile $gsbed \
    --score $within_family_path/processed/sbayesr/meta_with_ea4/estimates.posterior.formatted 12 5 8 header center \
    --out $within_family_path/processed/sbayesr/meta_with_ea4/pgi

plink2 --bfile $gsbed \
    --score $within_family_path/processed/sbayesr/meta_no_ea4/estimates.posterior.formatted 12 5 8 header center \
    --out $within_family_path/processed/sbayesr/meta_no_ea4/pgi