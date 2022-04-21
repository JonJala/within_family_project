'''
Formats sumstats from our meta analysis
and EA4 reference panels
'''

import numpy as np
import pandas as pd

ea_meta = pd.read_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/package_output/ea/ea_meta_analysis.csv",
    delim_whitespace = True
)

ea_meta_dir = ea_meta[["SNP", "CHR", "BP", "Allele1", "Allele2", "f", "z_dir", "pval_dir", "wt_dir"]]
ea_meta_dir = ea_meta_dir.rename(
    columns = {
        "SNP" : "snpid",
        "CHR" : "chr",
        "BP" : "bpos",
        "Allele1" : "a1",
        "Allele2" : "a2",
        "f" : "freq",
        "z_dir" : "z",
        "pval_dir" : "pval",
        "wt_dir" : "n"
    }
)

ea_meta_dir.to_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/mtag/inputs/ea_meta_dir.sumstats",
    index = False,
    sep = " ",
    na_rep = "."
)


ea_meta_pop = ea_meta[["SNP", "CHR", "BP", "Allele1", "Allele2", "f", "z_population", "pval_population", "wt_2"]]
ea_meta_pop = ea_meta_pop.rename(
    columns = {
        "SNP" : "snpid",
        "CHR" : "chr",
        "BP" : "bpos",
        "Allele1" : "a1",
        "Allele2" : "a2",
        "f" : "freq",
        "z_population" : "z",
        "pval_population" : "pval",
        "wt_2" : "n"
    }
)

ea_meta_pop.to_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/mtag/inputs/ea_meta_pop.sumstats",
    index = False,
    sep = " ",
    na_rep = "."
)


ea_meta_avgparental = ea_meta[["SNP", "CHR", "BP", "Allele1", "Allele2", "f", "z_avgparental", "pval_avgparental", "wt_2"]]
ea_meta_avgparental = ea_meta_avgparental.rename(
    columns = {
        "SNP" : "snpid",
        "CHR" : "chr",
        "BP" : "bpos",
        "Allele1" : "a1",
        "Allele2" : "a2",
        "f" : "freq",
        "z_avgparental" : "z",
        "pval_avgparental" : "pval",
        "wt_2" : "n"
    }
)

ea_meta_avgparental.to_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/mtag/inputs/ea_meta_avgparental.sumstats",
    index = False,
    sep = " ",
    na_rep = "."
)

ea4_excl = pd.read_csv(
    "/disk/genetics4/projects/EA4/derived_data/Meta_analysis/5_Excl_UKBrel_STR_GS/2020_08_21/output/EA4_excl_UKBrel_STR_GS_2020_08_21.meta",
    delim_whitespace = True
)

ea4_excl = ea4_excl[['Chr', 'BP', 'rsID', 'EA', 'OA', 'EAF', 'Z', 'P', 'N']]
ea4_excl = ea4_excl.rename(
    columns = {
        'Chr' : 'chr',
        'BP' : 'bpos',
        'rsID' : 'snpid',
        'EA' : 'a1',
        'OA' : 'a2',
        'EAF' : 'freq',
        'Z' : 'z',
        'P' : 'p',
        'N' : 'n'
    }
)

ea4_excl.to_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/mtag/inputs/ea4_excl_ukb_gs_str.sumstats",
    index = False,
    sep = " ",
    na_rep = "."
)

ea4_full = pd.read_csv(
    "/disk/genetics4/projects/EA4/derived_data/Meta_analysis/1_Main/2020_08_20/output/EA4_2020_08_20.meta",
    delim_whitespace = True
)

ea4_full = ea4_full[['Chr', 'BP', 'rsID', 'EA', 'OA', 'EAF', 'Z', 'P', 'N']]
ea4_full = ea4_full.rename(
    columns = {
        'Chr' : 'chr',
        'BP' : 'bpos',
        'rsID' : 'snpid',
        'EA' : 'a1',
        'OA' : 'a2',
        'EAF' : 'freq',
        'Z' : 'z',
        'P' : 'p',
        'N' : 'n'
    }
)

ea4_full.to_csv(
    "/var/genetics/proj/within_family/within_family_project/processed/mtag/inputs/ea4.sumstats",
    index = False,
    sep = " ",
    na_rep = "."
)


