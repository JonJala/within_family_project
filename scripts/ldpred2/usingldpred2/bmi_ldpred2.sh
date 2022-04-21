within_family_path="/var/genetics/proj/within_family/within_family_project"

# Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
#     --bfile "/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/plink/final/mcs" \
#     --sumstats "${within_family_path}/processed/package_output/bmi/bmi_meta_newqc.csv" \
#     --bed_backup "${within_family_path}/processed/package_output/bmi/bmi_meta_newqc" \
#     --outfile "${within_family_path}/processed/ldpred2/bmi_pgi_population" \
#     --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "population_N" \
#     --beta "population_Beta" --beta_se "population_SE"

Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
    --read_ldmat "${within_family_path}/scripts/ldpred2/reference_panel_ukb_eur/LD_chr~.rds,${within_family_path}/scripts/ldpred2/reference_panel_ukb_eur/map.rds" \
    --sumstats "${within_family_path}/processed/package_output/bmi/bmi_meta_newqc.csv" \
    --bed_backup "${within_family_path}/processed/package_output/bmi/bmi_meta_newqc" \
    --outfile "${within_family_path}/processed/ldpred2/bmi_pgi_population" \
    --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "population_N" \
    --beta "population_Beta" --beta_se "population_SE"


# Rscript ${within_family_path}/scripts/ldpred2/runldpred2.R \
#     --bfile "/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/plink/final/mcs" \
#     --sumstats "${within_family_path}/processed/package_output/bmi/bmi_meta_newqc.csv" \
#     --bed_backup "${within_family_path}/processed/package_output/bmi/bmi_meta_newqc" \
#     --outfile "${within_family_path}/processed/ldpred2/bmi_pgi_direct" \
#     --chr "CHR" --pos "BP" --rsid "SNP" --a1 "A1" --a2 "A2" --N_col "dir_N" \
#     --beta "dir_Beta" --beta_se "dir_SE" \
#     --predout


