#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
bedfilepath="/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/genotypes/chr_*.bed"

for file in $bedfilepath
do
    # extracts chromosome number
    chrno=$(echo ${file:70:3} | tr -dc '0-9')
    echo $chrno

    # cuts the .bed extension at the end
    filenobed=$(echo ${file::-4})
    echo $filenobed

    plink1 \
        --bfile $filenobed \
        --keep ${within_family_path}/processed/fpgs/observed_gts_gs/observed_gts_gs.fam \
        --make-bed \
        --out ${within_family_path}/processed/fpgs/observed_gts_gs/chr_$chrno
done