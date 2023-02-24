
raw_sumstats=$1
snp_field=$2
p_field=$3
out_prefix=$4

# using a different version of plink1.9 to what's on the server due to errors when using server version

for chr in {1..22}; do

    echo ${chr}

    /var/genetics/proj/within_family/plink1.9/plink --bfile /disk/genetics2/HRC/aokbay/LDgf/Full/perChr_rsid/HRC_geno05_mind01_maf001_hwe1e-10_rel025_nooutliers_chr$chr \
    --clump ${raw_sumstats} \
    --clump-snp-field ${snp_field} \
    --clump-p1 5e-8 \
    --clump-p2 5e-8 \
    --clump-field ${p_field} \
    --clump-r2 0.1 \
    --clump-kb 1000000 \
    --out "${out_prefix}.chr${chr}" &
done
wait