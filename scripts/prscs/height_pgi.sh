#!/bin/bash

gctb="/disk/genetics/ukb/aokbay/bin/gctb_2.03beta_Linux/gctb"
dirout="/var/genetics/proj/within_family/within_family_project/processed/sbayesr"
within_family_path="/var/genetics/proj/within_family/within_family_project"
refldpanel="/disk/genetics/tools/gctb/ld_reference/ukbEURu_hm3_shrunk_sparse/ukbEURu_mldmlist.txt"

N_THREADS=1
export MKL_NUM_THREADS=${N_THREADS}
export OMP_NUM_THREADS=${N_THREADS}
export NUMEXPR_NUM_THREADS=${N_THREADS}

for chr in {1..22}; do
prscs \
    --ref_dir=/disk/genetics/tools/gctb/ld_reference/ukbEURu_hm3_shrunk_sparse/ukbEURu_mldmlist.txt \
    --bim_prefix=${bim_path} \
    --sst_file=/var/genetics/proj/alz_pgi/alz_pgi_project/processed/kunkle/4_prscs/kunkle_sumstats_prscs.txt \
    --n_gwas=76299 \
    --chrom=${chr} \
    --seed=1 \
    --out_dir=${dirout} &
done
wait