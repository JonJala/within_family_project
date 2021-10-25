#!/usr/bin/bash
### Run the easyqc pipeline

#####################
# ====== UKB ====== #
#####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/21/chr_*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/ea" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     -bim_chromosome 99 \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz"




#######################
# generation scotland
#######################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/14/chr_*.sumstatschr_clean.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/gs/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --rsid_readfrombim "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/SNPs/chr_*_rsids.txt,0,3,1, " \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --hwe "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/hwe/chr_*.hwe" \
#     --info "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/info/combined_clean.info.gz"

# 0.7833 (0.1071)


#############
# LIfelines
##########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_edu.sumstats" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --effects "direct_averageparental" \
#     --toest "direct_population"
# 0.8158 (0.1438)


###########
# MOBA
############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/sumstats/edu_chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/moba/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population"
# 0.9331 (0.3353)

#########
# Estonian Biobank
#########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/EduYears/EduYears_chr*_results.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population"

# 0.9528 (0.0496)

##########
# STR
##########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/eduYears/eduYears_chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_population" \
#     --bim_bp 3 --bim_a1 4 --bim_a2 5
# 0.9303 (0.5006)

#####
# Finnish twins
#####

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/EA.chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_population"

# cant be computed


#########
# Hunt
######


python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/ea/Eduhunt_results_chr*.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/ea" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "
# 1.0875 (0.1359)

#################
# Minnesotta twins
#################

# NEED TO PUT THIS IN