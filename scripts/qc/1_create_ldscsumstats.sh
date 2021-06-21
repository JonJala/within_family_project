#!/usr/bin/bash

# Intended to convert all hdf5 to LDSC ready sumstats

sldsc_path="/homes/nber/harij/gitrepos/SNIPar/ldsc_reg"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

bash /var/genetics/data/str/public/latest/processed/sumstats/fgwas/mksumstats.sh
bash /var/genetics/data/hunt/public/latest/processed/sumstats/fgwas/mksumstats.sh
bash /var/genetics/data/gen_scotland/public/latest/processed/sumstats/fgwas/mksumstats.sh
bash /var/genetics/data/finn_twin/public/latest/processed/sumstats/fgwas/mksumstats.sh
bash /var/genetics/data/estonian_biobank/public/latest/processed/sumstats/fgwas/mksumstats.sh
bash /var/genetics/data/ukb/public/latest/processed/sumstats/fgwas/mksumstats.sh
bash /var/genetics/data/moba/public/latest/processed/sumstats/fgwas/mksumstats.sh




