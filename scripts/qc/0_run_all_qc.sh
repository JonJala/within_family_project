#!/usr/bin/bash

# Intended to convert all hdf5 to LDSC ready sumstats

sldsc_path="/homes/nber/harij/gitrepos/SNIPar/ldsc_reg"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
ssgacrepo="/homes/nber/harij/ssgac"


bash /var/genetics/proj/within_family/within_family_project/scripts/qc/1_create_ldscsumstats.sh
# bash /var/genetics/proj/within_family/within_family_project/scripts/qc/2_qc_sumstats.sh

