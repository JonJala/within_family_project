#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/adhd_ref/adhd_ref.sumstats.gz"


# ##############
# ## Geisinger
# #############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.ASTHMA.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/adhd" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --info '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/info.formatted.txt' \
#     --hwe '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/hwe.formatted.txt' \
#     --binary

# #####
# ## Finnish twins
# #####

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/ADHD.chr*.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ft/adhd" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_population" \
#     --hwe "/var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/hardy.hwe" \
#     --info /"var/genetics/data/finn_twin/public/latest/raw/sumstats/fgwas/snpstats/info.txt" \
#     --binary

################
## iPSYCH
############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/ipsych/private/v1/processed/sumstats/sumstats_adhd_export0.txt" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ipsych/adhd" \
    --toest "direct_population" \
    --ldsc-ref "$reffile" \
    --cptid \
    --binary