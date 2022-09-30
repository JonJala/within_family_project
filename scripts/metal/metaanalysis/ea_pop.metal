# METAL PATH = /var/genetics/pub/software/metal/generic-metal/metal   
MARKER rsID
ALLELE EFFECT_ALLELE OTHER_ALLELE
PVALUE PVAL
EFFECT BETA
WEIGHT N


PROCESS /var/genetics/data/str/public/latest/processed/sumstats/fgwas/eduYears/eduYears_qced_pop/CLEANED.eduYears_ldsc_pop.1.gz
PROCESS /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/ea/Eduhunt_qced_pop/CLEANED.Eduhunt_ldsc_pop.1.gz
PROCESS /var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/10/EA_qced_pop/CLEANED.ldsc_pop.3.gz
PROCESS /var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/EA_qced_pop/CLEANED.EA_pop.1.gz
PROCESS /var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/21/ea_pop_qced/CLEANED.ea_pop.2.gz

OUTFILE /var/genetics/proj/within_family/within_family_project/processed/metal_output/metal_pop_ea .tbl
ANALYZE

QUIT