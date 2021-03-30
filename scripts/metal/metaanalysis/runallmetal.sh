#!/usr/bin/bash


metal="/var/genetics/pub/software/metal/generic-metal/metal"

$metal /var/genetics/proj/within_family/within_family_project/scripts/metal/metaanalysis/bmi_avgparental.metal
$metal /var/genetics/proj/within_family/within_family_project/scripts/metal/metaanalysis/bmi_pop.metal
$metal /var/genetics/proj/within_family/within_family_project/scripts/metal/metaanalysis/bmi_dir.metal

$metal /var/genetics/proj/within_family/within_family_project/scripts/metal/metaanalysis/ea_avgparental.metal
$metal /var/genetics/proj/within_family/within_family_project/scripts/metal/metaanalysis/ea_pop.metal
$metal /var/genetics/proj/within_family/within_family_project/scripts/metal/metaanalysis/ea_dir.metal