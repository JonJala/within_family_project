# METAL PATH = /var/genetics/pub/software/metal/generic-metal/metal
MARKER rsID
ALLELE EFFECT_ALLELE OTHER_ALLELE
PVALUE PVAL
EFFECT BETA
WEIGHT N

PROCESS /var/genetics/data/str/public/latest/processed/sumstats/fgwas/bmi/bmi_qced_pop/CLEANED.bmi_ldsc_pop.gz
PROCESS /var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/6/bmi_qced_pop/CLEANED.ldsc_pop.gz
PROCESS /var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/bmi_qced_pop/CLEANED.bmi_pop.gz
PROCESS /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/bmi_pop_qced/CLEANED.bmi_pop.gz
PROCESS /var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/13/bmi_pop_qced/CLEANED.bmi_pop.gz

OUTFILE /var/genetics/proj/within_family/within_family_project/processed/metal_output/metal_pop_bmi .tbl
ANALYZE

QUIT