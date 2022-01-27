#!/usr/bin/bash
### Run the easyqc pipeline

#####################
# ====== UKB ====== #
#####################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/21/chr_*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ukb/ea" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --bim_chromosome 99 \
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

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/disk/genetics/data/lifelines/public/latest/raw/sumstats/fgwas/fgwas_ll_edu.sumstats" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/lifelines/ea" \
    --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --info "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt" \
    --hwe "/disk/genetics3/data_dirs/lifelines/public/v1/raw/sumstats/fgwas/fgwas_ll_info_hwe.formatted.txt"
# 0.8028 (0.1378)


##########
# MOBA
############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/moba/public/latest/raw/sumstats/fgwas/sumstats/edu_chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/moba/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population"
# # 0.9331 (0.3353)

#########
# Estonian Biobank
#########


# estonian bio bnak with controls
# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/EduYears/controls/EduYears_ext/EduYears_chr*_results.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/ea/controls" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --hwe "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/hwe/chr_*.hwe" \
#     --info "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/info/combined_clean.info.gz"
# # 0.9661 (0.053)

##########
# STR
##########

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/str/public/latest/raw/sumstats/fgwas/eduYears/eduYears_chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/str/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_population" \
#     --bim_bp 3 --bim_a1 4 --bim_a2 5
# # 0.9303 (0.5006)

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


# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/edu/edu_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/hunt/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --rsid_readfrombim "/var/genetics/data/hunt/public/latest/raw/sumstats/fgwas/bimfiles/Eduhunt_results_chr*.bim,0,2,1, "

################
# Minnesotta twins
################

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/minn_twins/public/latest/raw/sumstats/fgwas/sumstats/ED_chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/minn_twins/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --cptid \
#     --toest "direct_population"

    # 0.5782 (0.2655)

################
# Geisinger
############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.Edu_Years.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population"
# # 1.0865 (0.332)

#############
# Dutch Twins
#############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Education/NTR_Education_CHR*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/ea" \
#     --ldsc-ref "/var/genetics/proj/within_family/within_family_project/processed/reference_samples/ea_ref/GWAS_EA_excl23andMe.sumstats.gz" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --cptid \
#     --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
#     --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"