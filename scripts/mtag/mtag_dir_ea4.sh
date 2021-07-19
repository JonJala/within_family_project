within_family_path="/var/genetics/proj/within_family/within_family_project"
mtag_path="/var/genetics/pub/software/mtag"

python ${mtag_path}/mtag.py \
    --sumstats ${within_family_path}/processed/mtag/inputs/ea_meta_dir.sumstats,${within_family_path}/processed/mtag/inputs/ea4_excl_ukb_gs_str.sumstats \
    --out ${within_family_path}/processed/mtag/dir_ea4

python ${mtag_path}/mtag.py \
    --sumstats ${within_family_path}/processed/mtag/inputs/ea_meta_pop.sumstats,${within_family_path}/processed/mtag/inputs/ea4_excl_ukb_gs_str.sumstats \
    --out ${within_family_path}/processed/mtag/pop_ea4

python ${mtag_path}/mtag.py \
    --sumstats ${within_family_path}/processed/mtag/inputs/ea_meta_avgparental.sumstats,${within_family_path}/processed/mtag/inputs/ea4_excl_ukb_gs_str.sumstats \
    --out ${within_family_path}/processed/mtag/avgparental_ea4

# Combine Dir x Average par X EA4

python ${mtag_path}/mtag.py \
    --sumstats ${within_family_path}/processed/mtag/inputs/ea_meta_dir.sumstats,${within_family_path}/processed/mtag/inputs/ea_meta_avgparental.sumstats,${within_family_path}/processed/mtag/inputs/ea4_excl_ukb_gs_str.sumstats \
    --out ${within_family_path}/processed/mtag/dir_avgparental_ea4
