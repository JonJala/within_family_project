#!/bin/bash

cd "/var/genetics/proj/within_family/within_family_project/processed/qc/ckb/allele_freq"

# for chr in {1..22}; do
#       plink2 --bfile /var/genetics/data/1000G/public/20130502/processed/gen/EAS/EAS_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502 --make-pgen --out /var/genetics/data/1000G/public/20130502/processed/gen/EAS/plink2/EAS_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502
# done

plink2 --pmerge-list /var/genetics/data/1000G/public/20130502/processed/gen/EAS/plink2/EAS_allchr_files.txt \
      --set-all-var-ids "@:#" \
      --freq cols=-chrom,+reffreq,-altfreq,-nobs

sed "1s/.*/ChrPosID\ta1\ta2\tfreq1/" /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/eas_afs/plink2.afreq > /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/eas_afs/eas_1kg.frq