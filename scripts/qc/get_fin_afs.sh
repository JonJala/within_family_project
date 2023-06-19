#!/usr/bin/env bash

# -----------------------------------------------------------------------------------------------------------------
## get finnish af ref file 
# -----------------------------------------------------------------------------------------------------------------

cd /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/fin_afs

plink2 --pmerge-list /var/genetics/data/1000G/public/20130502/processed/genotyped/fin/plink2/fin_allchr_files.txt \
      --set-all-var-ids "@:#" \
      --freq cols=-chrom,+reffreq,-altfreq,-nobs

sed "1s/.*/ChrPosID    a1    a2    freq1/" /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/fin_afs/plink2.afreq > /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/fin_afs/fin_1kg.frq