#!/usr/bin/bash
### Run the easyqc pipeline

reffile="/var/genetics/proj/within_family/within_family_project/processed/reference_samples/hayfever_ref/hayfever_ref.sumstats.gz"

# ##############
# # Estonian Biobank
# ##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/Hayfever-ext/hayfever_chr*_results.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/estonian_biobank/hayfever" \
#     --ldsc-ref $reffile \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --hwe "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/HWE/chr*.hwe" \
#     --info "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/ImputationQuality_formatted.TXT" \
#     --binary

# ###############
# # Geisinger
# ##############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT/fGWAS.OUT.GHS145k.hg38.GSA.OMNI.EUR.sampleQC.PCA.WF_GWAS.HAYFEVER.chr*.sumstats.hdf5" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/geisinger/hayfever" \
#     --ldsc-ref $reffile \
#     --toest "direct_paternal_maternal_averageparental_population" \
#     --info '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/info.formatted.txt' \
#     --hwe '/var/genetics/data/geisinger/public/latest/raw/sumstats/fgwas/OUTPUT.SNP_INFO/hwe.formatted.txt' \
#     --binary

# ################
# # iPSYCH
# ############

# python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
#     "/var/genetics/data/ipsych/public/latest/processed/sumstats/sumstats_hayfever_export0.txt" \
#     --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/ipsych/hayfever" \
#     --toest "direct_population" \
#     --cptid \
#     --ldsc-ref $reffile \
#     --binary

############
# Finn Gen
############

python /var/genetics/proj/within_family/within_family_project/scripts/package/qc/run_easyqc.py \
    "/var/genetics/data/finngen/private/v1/processed/sumstats/allergic_rhinitis.sumstats.gz" \
    --outprefix "/var/genetics/proj/within_family/within_family_project/processed/qc/finngen/hayfever" \
    --ldsc-ref "$reffile" \
    --af-ref /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/fin_afs/fin_1kg.frq \
    --cptid \
    --effects "direct_averageparental" \
    --toest "direct_population" \
    --binary