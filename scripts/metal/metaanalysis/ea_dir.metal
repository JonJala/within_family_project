# METAL PATH = /var/genetics/pub/software/metal/generic-metal/metal
MARKER rsID
ALLELE EFFECT_ALLELE OTHER_ALLELE
PVALUE PVAL
EFFECT BETA
WEIGHT N




PROCESS /var/genetics/data/str/public/latest/processed/sumstats/fgwas/eduYears/eduYears_qced_dir/CLEANED.eduYears_ldsc_dir.2.gz
PROCESS /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/ea/Eduhunt_qced_dir/CLEANED.Eduhunt_ldsc_dir.2.gz
PROCESS /var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/10/EA_qced_dir/CLEANED.ldsc_dir.3.gz
PROCESS /var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/EA_qced_dir/CLEANED.EA_dir.1.gz
PROCESS /var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/21/ea_dir_qced/CLEANED.ea_dir.2.gz

OUTFILE /var/genetics/proj/within_family/within_family_project/processed/metal_output/metal_dir_ea .tbl
ANALYZE

QUIT