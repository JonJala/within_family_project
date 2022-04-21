within_family_path="/var/genetics/proj/within_family/within_family_project"
ukbwhitebrit="/var/genetics/data/ukb/private/latest/processed/user/harij/projects/within_family/data/ukb_chr1_22_geno01_maf001_hwe10e6_500k_whitebritish"
gsbed="/disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3"



# MTAG PGIs
# Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
#     --bfile $gsbed \
#     --sumstats "${within_family_path}/processed/mtag/dir_ea4_trait_1.txt" \
#     --outfile "${within_family_path}/processed/ldpred2/ea_pgi_mtag_dir" \
#     --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "N" \
#     --beta "mtag_beta" --beta_se "mtag_se" \
#     --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
#     --predout --scale_pgi


# Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
#     --bfile $gsbed \
#     --sumstats "${within_family_path}/processed/mtag/pop_ea4_trait_1.txt" \
#     --outfile "${within_family_path}/processed/ldpred2/ea_pgi_mtag_pop" \
#     --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "N" \
#     --beta "mtag_beta" --beta_se "mtag_se" \
#     --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
#     --predout --scale_pgi


# Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
#     --bfile $gsbed \
#     --sumstats "${within_family_path}/processed/mtag/avgparental_ea4_trait_1.txt" \
#     --outfile "${within_family_path}/processed/ldpred2/ea_pgi_mtag_avgparental" \
#     --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "N" \
#     --beta "mtag_beta" --beta_se "mtag_se" \
#     --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
#     --predout --scale_pgi

# Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
#     --bfile $gsbed \
#     --sumstats "${within_family_path}/processed/mtag/dir_avgparental_ea4_trait_1.txt" \
#     --outfile "${within_family_path}/processed/ldpred2/ea_dir_avgparental_ea4_mtag_dir" \
#     --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "N" \
#     --beta "mtag_beta" --beta_se "mtag_se" \
#     --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
#     --predout --scale_pgi

# Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
#     --bfile $gsbed \
#     --sumstats "${within_family_path}/processed/mtag/dir_avgparental_ea4_trait_2.txt" \
#     --outfile "${within_family_path}/processed/ldpred2/ea_dir_avgparental_ea4_mtag_avgparental" \
#     --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "N" \
#     --beta "mtag_beta" --beta_se "mtag_se" \
#     --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
#     --predout --scale_pgi

Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
    --bfile $gsbed \
    --sumstats "${within_family_path}/processed/mtag/dir_ea4_sldsc_trait_1.txt" \
    --outfile "${within_family_path}/processed/ldpred2/ea_dir_ea4_sldsc_mtag_dir" \
    --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "N" \
    --beta "mtag_beta" --beta_se "mtag_se" \
    --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
    --predout --scale_pgi