# METAL PATH = /var/genetics/pub/software/metal/generic-metal/metal
SEPERATOR TAB    
MARKER rsID
ALLELE EFFECT_ALLELE OTHER_ALLELE
PVALUE PVAL
EFFECT BETA
WEIGHT N

PROCESS /var/genetics/data/str/public/latest/processed/sumstats/fgwas/eduYears/eduYears_qced_avgparental/CLEANED.eduYears_ldsc_avgparental
PROCESS /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/ea/Eduhunt_qced_avgparental/CLEANED.Eduhunt_ldsc_avgparental
PROCESS /var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/10/EA_qced_avgparental/CLEANED.ldsc_avgparental
PROCESS /var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/EA_qced_avgparental/CLEANED.EA_avgparental
PROCESS var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/21/ea_avgparental_qced/CLEANED.ea_avgparental

OUTFILE /var/genetics/proj/within_family/within_family_project/processed/metal_output/metal_avgparental_ea .tbl
ANALYZE

QUIT