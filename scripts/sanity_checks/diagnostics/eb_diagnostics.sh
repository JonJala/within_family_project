#!/usr/bin/bash

scriptpath="/var/genetics/proj/within_family/within_family_project/scripts/package"
sniparpath="/homes/nber/harij/gitrepos/SNIPar"
eur_w_ld_chr="/var/genetics/pub/data/ld_ref_panel/eur_w_ld_chr"

python $scriptpath/diagnostics.py \
"/var/genetics/proj/within_family/within_family_project/scripts/sanity_checks/diagnostics/eb_diagnostics.json" \
--outprefix "/var/genetics/proj/within_family/within_family_project/processed/sanity_checks/eb/diagnostics/"


#  "smoking" : {
#         "path2file" : "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/smoke/SMOKE_chr*_results.sumstats.hdf5",
#         "bim" : "bim",
#         "bim_chromosome" : 0,
#         "bim_bp" : 2,
#         "bim_rsid" : 1,
#         "bim_a1" : 3,
#         "bim_a2" : 4,
#         "estimate" : "estimate",
#         "estimate_ses" : "estimate_ses",
#         "estimate_covariance" : "estimate_covariance",
#         "sigma2" : "sigma2",
#         "tau" : "tau",
#         "freqs" : "freqs",
#         "rsid_readfrombim" : "",
#         "maf" : 1,
#         "Amat" : {
#             "3" : "1.0 0.0;0.0 1.0;0.0 1.0"
#         },
#         "effect_transform" : "full"
        
        
#         },
    
#     "aafb" : {
#         "path2file" : "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/aafb/AGE-First-BIRTH/AGE_chr*_results.sumstats.hdf5",
#         "bim" : "bim",
#         "bim_chromosome" : 0,
#         "bim_bp" : 2,
#         "bim_rsid" : 1,
#         "bim_a1" : 3,
#         "bim_a2" : 4,
#         "estimate" : "estimate",
#         "estimate_ses" : "estimate_ses",
#         "estimate_covariance" : "estimate_covariance",
#         "sigma2" : "sigma2",
#         "tau" : "tau",
#         "freqs" : "freqs",
#         "rsid_readfrombim" : "",
#         "maf" : 1,
#         "Amat" : {
#             "3" : "1.0 0.0;0.0 1.0;0.0 1.0"
#         },
#         "effect_transform" : "full"
        
#         },
    
#     "bmi" : {
#         "path2file" : "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/newresults/bmi/BMI/BMI_chr*_results.sumstats.hdf5",
#         "bim" : "bim",
#         "bim_chromosome" : 0,
#         "bim_bp" : 2,
#         "bim_rsid" : 1,
#         "bim_a1" : 3,
#         "bim_a2" : 4,
#         "estimate" : "estimate",
#         "estimate_ses" : "estimate_ses",
#         "estimate_covariance" : "estimate_covariance",
#         "sigma2" : "sigma2",
#         "tau" : "tau",
#         "freqs" : "freqs",
#         "rsid_readfrombim" : "",
#         "maf" : 1,
#         "Amat" : {
#             "3" : "1.0 0.0;0.0 1.0;0.0 1.0"
#         },
#         "effect_transform" : "full"
#         },


#     "asthma" : {
#         "path2file" : "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/asthma/ASTHMA/ASTHMA_chr*_results.sumstats.hdf5",
#         "bim" : "bim",
#         "bim_chromosome" : 0,
#         "bim_bp" : 2,
#         "bim_rsid" : 1,
#         "bim_a1" : 3,
#         "bim_a2" : 4,
#         "estimate" : "estimate",
#         "estimate_ses" : "estimate_ses",
#         "estimate_covariance" : "estimate_covariance",
#         "sigma2" : "sigma2",
#         "tau" : "tau",
#         "freqs" : "freqs",
#         "rsid_readfrombim" : "",
#         "maf" : 1,
#         "Amat" : {
#             "3" : "1.0 0.0;0.0 1.0;0.0 1.0"
#         },
#         "effect_transform" : "full"
        
        
#         },

#     "depression" : {
#         "path2file" : "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/depression/Depression/Depression_chr*_results.sumstats.hdf5",
#         "bim" : "bim",
#         "bim_chromosome" : 0,
#         "bim_bp" : 2,
#         "bim_rsid" : 1,
#         "bim_a1" : 3,
#         "bim_a2" : 4,
#         "estimate" : "estimate",
#         "estimate_ses" : "estimate_ses",
#         "estimate_covariance" : "estimate_covariance",
#         "sigma2" : "sigma2",
#         "tau" : "tau",
#         "freqs" : "freqs",
#         "rsid_readfrombim" : "",
#         "maf" : 1,
#         "Amat" : {
#             "3" : "1.0 0.0;0.0 1.0;0.0 1.0"
#         },
#         "effect_transform" : "full"
        
        
#         },


#     "eczema" : {
#         "path2file" : "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/eczema/Eczema/Eczema_chr*_results.sumstats.hdf5",
#         "bim" : "bim",
#         "bim_chromosome" : 0,
#         "bim_bp" : 2,
#         "bim_rsid" : 1,
#         "bim_a1" : 3,
#         "bim_a2" : 4,
#         "estimate" : "estimate",
#         "estimate_ses" : "estimate_ses",
#         "estimate_covariance" : "estimate_covariance",
#         "sigma2" : "sigma2",
#         "tau" : "tau",
#         "freqs" : "freqs",
#         "rsid_readfrombim" : "",
#         "maf" : 1,
#         "Amat" : {
#             "3" : "1.0 0.0;0.0 1.0;0.0 1.0"
#         },
#         "effect_transform" : "full"
        
        
#         },

#     "mdd" : {
#         "path2file" : "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/mdd/MDD_chr*_results.sumstats.hdf5",
#         "bim" : "bim",
#         "bim_chromosome" : 0,
#         "bim_bp" : 2,
#         "bim_rsid" : 1,
#         "bim_a1" : 3,
#         "bim_a2" : 4,
#         "estimate" : "estimate",
#         "estimate_ses" : "estimate_ses",
#         "estimate_covariance" : "estimate_covariance",
#         "sigma2" : "sigma2",
#         "tau" : "tau",
#         "freqs" : "freqs",
#         "rsid_readfrombim" : "",
#         "maf" : 1,
#         "Amat" : {
#             "3" : "1.0 0.0;0.0 1.0;0.0 1.0"
#         },
#         "effect_transform" : "full"
        
        
#         },

#     "migraine" : {
#         "path2file" : "/var/genetics/data/estonian_biobank/public/latest/raw/sumstats/fgwas/migraine/Migraine/Migraine_chr*_results.sumstats.hdf5",
#         "bim" : "bim",
#         "bim_chromosome" : 0,
#         "bim_bp" : 2,
#         "bim_rsid" : 1,
#         "bim_a1" : 3,
#         "bim_a2" : 4,
#         "estimate" : "estimate",
#         "estimate_ses" : "estimate_ses",
#         "estimate_covariance" : "estimate_covariance",
#         "sigma2" : "sigma2",
#         "tau" : "tau",
#         "freqs" : "freqs",
#         "rsid_readfrombim" : "",
#         "maf" : 1,
#         "Amat" : {
#             "3" : "1.0 0.0;0.0 1.0;0.0 1.0"
#         },
#         "effect_transform" : "full"
        
        
#         },