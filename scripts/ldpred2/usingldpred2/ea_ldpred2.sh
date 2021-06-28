within_family_path="/var/genetics/proj/within_family/within_family_project"
ukbwhitebrit="/var/genetics/data/ukb/private/latest/processed/user/harij/projects/within_family/data/ukb_chr1_22_geno01_maf001_hwe10e6_500k_whitebritish"
gsbed="/disk/genetics/sibling_consortium/GS20k/aokbay/imputed/HRC/plink/HM3/GS_HRC_HM3"


Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
    --bfile $gsbed \
    --sumstats "${within_family_path}/processed/package_output/ea/ea_meta_analysis.csv" \
    --outfile "${within_family_path}/processed/ldpred2/ea_pgi_direct" \
    --chr "CHR" --pos "BP" --rsid "SNP" --a1 "Allele1" --a2 "Allele2" --N_col "wt_dir" \
    --beta "beta_dir" --beta_se "beta_se_dir" \
    --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
    --predout


Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
    --bfile $gsbed \
    --sumstats "${within_family_path}/processed/ea_ref/GWAS_EA_excl23andMe.txt" \
    --outfile "${within_family_path}/processed/ldpred2/ea_pgi_ref" \
    --chr "CHR" --pos "POS" --rsid "MarkerName" --a1 "A1" --a2 "A2" --gwas_samplesize 1100000 \
    --beta "Beta" --beta_se "SE" \
    --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
    --predout


Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
    --bfile $gsbed \
    --sumstats "${within_family_path}/processed/package_output/ea/ea_meta_analysis.csv" \
    --outfile "${within_family_path}/processed/ldpred2/ea_pgi_pop" \
    --chr "CHR" --pos "BP" --rsid "SNP" --a1 "Allele1" --a2 "Allele2" --N_col "wt_2" \
    --beta "beta_population" --beta_se "beta_se_population" \
    --bed_backup "${within_family_path}/processed/ldpred2/GS_HRC_HM3.bk" \
    --predout


