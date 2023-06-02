#!/usr/bin/env bash

## copied and modified from /disk/genetics/data/1000G/public/20130502/scripts/conversion_scripts/vcftobed_151220.sh

set -e

INDIR="/var/genetics/data/1000G/public/20130502/raw/genotyped"
SAMPLESDIR="/var/genetics/data/1000G/public/20130502/processed/misc/samples"
DBSNP="/var/genetics/data/1000G/public/20130502/processed/misc/dbSNP"
BADSNPS="/var/genetics/data/1000G/public/20130502/processed/misc/merge_errors/bad_rsids.missnp"
SIBS="/var/genetics/data/1000G/public/20130502/scripts/vcftobed/sibs/remove_sibs.txt"
OUTDIR="/var/genetics/data/1000G/public/20130502/processed/genotyped"
vcftobed="/var/genetics/data/1000G/public/20130502/scripts/vcftobed/vcftobed.py"
pop="fin"

cd /var/genetics/data/1000G/public/20130502/scripts

cd vcftobed/dbsnp

for chr in {1..22}; do
    $vcftobed \
        --vcf "${INDIR}/ALL.chr${chr}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz" \
        --samples "${SAMPLESDIR}/${pop}_samples.txt" \
        --sex "${SAMPLESDIR}/coded_sex.txt" \
        --extract "${DBSNP}/extract/extract_chr${chr}.txt" \
        --maf 0.01 \
        --out "${OUTDIR}/${pop}/${pop}_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502" &
done

# -----------------------------------------------------------------------------------------------------------------
# # convert to bed
# -----------------------------------------------------------------------------------------------------------------

cd /var/genetics/data/1000G/public/20130502/scripts/conversion_scripts

if true; then
    for pop in "fin"; do
        : > "${OUTDIR}/${pop}/${pop}_allchr_files.txt"
        for chr in {1..22}; do
            {
                echo "${OUTDIR}/${pop}/${pop}_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502" >> "${OUTDIR}/${pop}/${pop}_allchr_files.txt"
                plink1 --bfile "${OUTDIR}/${pop}/${pop}_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502" \
                    --keep-allele-order \
                    --exclude ${BADSNPS} \
                    --make-bed \
                    --out "${OUTDIR}/${pop}/${pop}_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502"
                rm -f "${OUTDIR}/${pop}/${pop}_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502"*"~"
            } &
        done
        wait
    done
fi

# -----------------------------------------------------------------------------------------------------------------
## convert to af ref file
# -----------------------------------------------------------------------------------------------------------------

## convert to plink 2
for chr in {1..22}; do
      plink2 --bfile /disk/genetics/data/1000G/public/20130502/processed/genotyped/fin/fin_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502 --make-pgen --out /disk/genetics/data/1000G/public/20130502/processed/genotyped/fin/plink2/fin_chr${chr}_phase3_shapeit2_mvncall_integrated_v5a.20130502
done

cd /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/fin_afs

plink2 --pmerge-list /var/genetics/data/1000G/public/20130502/processed/genotyped/fin/plink2/fin_allchr_files.txt \
      --set-all-var-ids "@:#" \
      --freq cols=-chrom,+reffreq,-altfreq,-nobs

sed "1s/.*/ChrPosID    a1    a2    freq1/" /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/fin_afs/plink2.afreq > /var/genetics/proj/within_family/within_family_project/processed/qc/otherqc/fin_afs/fin_1kg.frq