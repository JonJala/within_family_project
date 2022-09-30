#!/usr/bin/bash

ldscpath="/homes/nber/harij/ldsc"
ldscmodpath="/homes/nber/harij/ssgac/ldsc_mod"
# eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
refld="/var/genetics/data/ukb/private/latest/processed/user/harij/projects/within_family/data/ldscores/ukb_chr@_geno01_maf001_hwe10e6_500k_removedwithdrawn_eur_unrelated"
within_family_path="/var/genetics/proj/within_family/within_family_project"
snplist="/var/genetics/proj/within_family/within_family_project/processed/genetic_mapping/rsid_segments.ldscsnplist"
scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"

echo "Munging!!"

source /disk/genetics/pub/python_env/anaconda2/bin/activate /disk/genetics/pub/python_env/anaconda2/envs/ldsc

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/meta.sumstats.gz \
# --out ${within_family_path}/processed/package_output/ea/direct.leadsnps \
# --N-col direct_N --p direct_pval --signed-sumstats direct_z,0 \
# --merge-alleles ${snplist} \
# --n-min 1.0

# ${ldscpath}/munge_sumstats.py \
# --sumstats ${within_family_path}/processed/package_output/ea/meta.sumstats.gz \
# --out ${within_family_path}/processed/package_output/ea/population.leadsnps \
# --N-col population_N --p population_pval --signed-sumstats population_z,0 \
# --merge-alleles ${snplist} \
# --n-min 1.0

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/ea/direct.leadsnps.sumstats.gz \
--ref-ld-chr ${refld} \
--w-ld-chr ${refld} \
--out ${within_family_path}/processed/package_output/ea/direct.leadsnps_h2

${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/package_output/ea/population.leadsnps.sumstats.gz \
--ref-ld-chr ${refld} \
--w-ld-chr ${refld} \
--out ${within_family_path}/processed/package_output/ea/population.leadsnps_h2