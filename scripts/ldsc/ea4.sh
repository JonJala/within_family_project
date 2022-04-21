ldscpath="/var/genetics/pub/software/ldsc"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr/"
within_family_path="/var/genetics/proj/within_family/within_family_project"
hm3snps="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"

# ${ldscpath}/munge_sumstats.py \
# --sumstats /disk/genetics4/projects/EA4/derived_data/Meta_analysis/1_Main/2020_08_20/output/EA4_2020_08_20.meta \
# --out ${within_family_path}/processed/ea4/ea4_formetanalysis_munged \
# --merge-alleles ${hm3snps} \
# --a1 EA --a2 OA --signed-sumstats Z,0 \
# --n-min 1.0


${ldscpath}/ldsc.py \
--h2 ${within_family_path}/processed/ea4/ea4_formetanalysis_munged.sumstats.gz \
--ref-ld-chr ${eur_w_ld_chr} \
--w-ld-chr ${eur_w_ld_chr} \
--out ${within_family_path}/processed/package_output/ea/meta_analysis_new_qc_avgpar_h2
# 0.0795 (0.0016)