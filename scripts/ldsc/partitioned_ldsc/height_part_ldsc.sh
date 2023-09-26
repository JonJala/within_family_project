#!/usr/bin/bash

## partitioned LDSC analysis for h2. based off /disk/genetics4/projects/EA4/code/partitionedLDSC/runldsc.sh

pheno="height"
effect="direct"
ldscpath="/disk/genetics2/pub/repo/ssgac/ldsc_mod"
merge_alleles="/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"
ea4_dir="/disk/genetics4/projects/EA4"
within_family_directory="/var/genetics/proj/within_family/within_family_project"

# == Using Phase 3 data == #
echo "Running Partitioned LDSC"
python ${ldscpath}/ldsc.py \
  --h2 ${within_family_directory}/processed/package_output/${pheno}/${effect}munged.sumstats.gz \
  --ref-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_baselineLD_ldscores/baselineLD. \
  --frqfile-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_frq/1000G.EUR.QC. \
  --w-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC. \
  --overlap-annot \
  --print-coefficients \
  --print-delete-vals \
  --out ${within_family_directory}/processed/ldsc/partitioned_ldsc/${pheno}/${effect}.baselineLD


echo "Using Cahoy et al annotations - baseline controls"
python ${ldscpath}/ldsc.py \
  --h2 ${within_family_directory}/processed/package_output/${pheno}/${effect}munged.sumstats.gz \
  --ref-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.1.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_baselineLD_ldscores/baselineLD. \
  --frqfile-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_frq/1000G.EUR.QC. \
  --w-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC. \
  --overlap-annot \
  --print-coefficients \
  --print-delete-vals \
  --out ${within_family_directory}/processed/ldsc/partitioned_ldsc/${pheno}/${effect}.cahoy.1

python ${ldscpath}/ldsc.py \
  --h2 ${within_family_directory}/processed/package_output/${pheno}/${effect}munged.sumstats.gz \
  --ref-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.2.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_baselineLD_ldscores/baselineLD. \
  --frqfile-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_frq/1000G.EUR.QC. \
  --w-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC. \
  --overlap-annot \
  --print-coefficients \
  --print-delete-vals \
  --out ${within_family_directory}/processed/ldsc/partitioned_ldsc/${pheno}/${effect}.cahoy.2

python ${ldscpath}/ldsc.py \
  --h2 ${within_family_directory}/processed/package_output/${pheno}/${effect}munged.sumstats.gz \
  --ref-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.3.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_baselineLD_ldscores/baselineLD. \
  --frqfile-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_frq/1000G.EUR.QC. \
  --w-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC. \
  --overlap-annot \
  --print-coefficients \
  --print-delete-vals \
  --out ${within_family_directory}/processed/ldsc/partitioned_ldsc/${pheno}/${effect}.cahoy.3

echo "Using Cahoy et al annotations - baseline controls + cahoy controls"

python ${ldscpath}/ldsc.py \
  --h2 ${within_family_directory}/processed/package_output/${pheno}/${effect}munged.sumstats.gz \
  --ref-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.1.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.control.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_baselineLD_ldscores/baselineLD. \
  --frqfile-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_frq/1000G.EUR.QC. \
  --w-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC. \
  --overlap-annot \
  --print-coefficients \
  --print-delete-vals \
  --out ${within_family_directory}/processed/ldsc/partitioned_ldsc/${pheno}/${effect}.cahoy.1.control


python ${ldscpath}/ldsc.py \
  --h2 ${within_family_directory}/processed/package_output/${pheno}/${effect}munged.sumstats.gz \
  --ref-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.2.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.control.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_baselineLD_ldscores/baselineLD. \
  --frqfile-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_frq/1000G.EUR.QC. \
  --w-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC. \
  --overlap-annot \
  --print-coefficients \
  --print-delete-vals \
  --out ${within_family_directory}/processed/ldsc/partitioned_ldsc/${pheno}/${effect}.cahoy.2.control

python ${ldscpath}/ldsc.py \
  --h2 ${within_family_directory}/processed/package_output/${pheno}/${effect}munged.sumstats.gz \
  --ref-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.3.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/Cahoy_1000Gv3_ldscores/Cahoy.control.,${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_baselineLD_ldscores/baselineLD. \
  --frqfile-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_frq/1000G.EUR.QC. \
  --w-ld-chr ${ea4_dir}/derived_data/partitionedLDSC/rawdata/1000G_Phase3_weights_hm3_no_MHC/weights.hm3_noMHC. \
  --overlap-annot \
  --print-coefficients \
  --print-delete-vals \
  --out ${within_family_directory}/processed/ldsc/partitioned_ldsc/${pheno}/${effect}.cahoy.3.control


echo "=================="
echo "Done! :)"
echo "=================="