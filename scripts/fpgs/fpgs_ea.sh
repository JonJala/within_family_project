#!/usr/bin/env bash
within_family_path="/var/genetics/proj/within_family/within_family_project"
snipar_path="/homes/nber/harij/gitrepos/SNIPar"
bgenfilepath="/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/genotypes/haplotypes/chr_~_haps"
bedfilepath="/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/genotypes/chr_~"
impfilespath="/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/imputed_phased/chr_~"


# format ldpred2 weight files for fpgs
python ${within_family_path}/scripts/fpgs/format_weights.py \
    ${within_family_path}/processed/ldpred2/ea_pgi_dir.wt.txt.gz \
    --compression "gzip" \
    --sep " " \
    --outfileprefix ${within_family_path}processed/ldpred2/ea_pgi_dir.wt \
    --sid-as-chrpos

python ${within_family_path}/scripts/fpgs/format_weights.py \
    ${within_family_path}/processed/ldpred2/ea_pgi_pop.wt.txt.gz \
    --compression "gzip" \
    --sep " " \
    --outfileprefix ${within_family_path}/processed/ldpred2/ea_pgi_pop.wt \
    --sid-as-chrpos

# generate pheno file
python $within_family_path/scripts/fpgs/format_pheno.py \
    /disk/genetics/sibling_consortium/GS20k/alextisyoung/processed_traits.fam \
    --iid IID --fid FID --phenocol EA \
    --outprefix $within_family_path/processed/fpgs/ea

# == Calculate PGIs == #
# Direct effects
python $snipar_path/fPGS.py \
    $within_family_path/processed/fpgs/direct_ea \
    --bedfiles $bedfilepath \
    --impfiles $impfilespath \
    --weights $within_family_path/processed/ldpred2/ea_pgi_dir.wt.txt

python $snipar_path/fPGS.py $within_family_path/processed/fpgs/direct_ea \
    --pgs $within_family_path/processed/fpgs/direct_ea.pgs.txt \
    --phenofile $within_family_path/processed/fpgs/ea.pheno \
    --scale_pgs


# Population Effects
python $snipar_path/fPGS.py \
    $within_family_path/processed/fpgs/pop_ea \
    --bedfiles $bedfilepath \
    --impfiles $impfilespath \
    --weights $within_family_path/processed/ldpred2/ea_pgi_pop.wt.txt

python $snipar_path/fPGS.py $within_family_path/processed/fpgs/pop_ea \
    --pgs $within_family_path/processed/fpgs/pop_ea.pgs.txt \
    --phenofile $within_family_path/processed/fpgs/ea.pheno \
    --scale_pgs