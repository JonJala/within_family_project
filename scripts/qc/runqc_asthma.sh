#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/asthma_ref/asthma_ref.sumstats.gz"

##############
# Estonian Biobank
##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/asthma/ASTHMA/ASTHMA_chr*_results.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/asthma" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population"


###############
# Geisinger
##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/asthma/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.ASTHMA.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/asthma" \
#     --ldsc-ref "$reffile" \
#     --toest "direct_paternal_maternal_averageparental_population"


#############
# Dutch Twins
#############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Asthma/NTR_Asthma_CHR*.sumstats.hdf5" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/dutch_twin/asthma" \
    --ldsc-ref "$reffile" \
    --toest "direct_paternal_maternal_averageparental_population" \
    --cptid \
    --info "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/info.txt.gz" \
    --hwe "/var/genetics/data/dutch_twin/public/latest/raw/sumstats/fgwas/Info/hwe.txt.gz"
