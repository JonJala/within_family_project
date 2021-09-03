import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import datetime as dt
import json

import matplotlib as mpl
mpl.rcParams['agg.path.chunksize'] = 10000

from parsedata import *


def print_sumstats(df_dict, df_args, transformto, hm3path = "/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"):
    
    hm3 = pd.read_csv(hm3path, delim_whitespace = True)
    df_sumstats = pd.DataFrame(columns = ['Dataset', 'Num. Obs', 'Num. Obs (HM3 SNPs)',
                                       'Mean f', 'Median f',
                                      'Mean Direct Effect', 'Median Direct Effect',
                                      'Mean 2nd Effect', 'Median 2nd Effect',
                                       'Mean Direct S', 'Median Direct S',
                                      'Mean 2nd Effect S', 'Median 2nd Effect S',
                                      'Mean Covariance', 'Median Covariance',
                                      'Phenotypic Variance'])
    
    for cohort in df_dict:
        
        dfin = df_dict[cohort]
        df_arg = df_args[cohort]
        
        
        theta = np.array(dfin[f'theta_{cohort}'].tolist())
        S = np.array(dfin[f'S_{cohort}'].tolist())
        S, theta = transform_estimates(df_arg['effect_transform'], transformto, S, theta)
        indir_effect_name = df_arg['effect_transform'].split('_')[-1]
        print(f'Second effect is: {indir_effect_name}')
        
        
        # filtering hm3
        ii = np.array([True for i in range(len(dfin))])
        ii = dfin['SNP'].isin(hm3['SNP'])
        if ii.sum() == 0:
            pass
        dfout = dfin[ii].reset_index(drop=True)
        
        df_sumstatsi = pd.DataFrame({
            'Dataset' : cohort,
            'Num. Obs' : format(dfin.shape[0], ","),
            'Num. Obs (HM3 SNPs)' : format(dfout.shape[0], ","),
            'Mean f' : format(dfin[f'f_{cohort}'].mean(), ".3f"),
            'Median f' : format(dfin[f'f_{cohort}'].median(), ".3f"),
            'Mean Direct Effect' : format(np.mean(theta[:, 0]), ".3f"),
            'Median Direct Effect' : format(np.median(theta[:, 0]), ".3f"),
            'Mean 2nd Effect' : format(np.mean(theta[:, 1]), ".3f"),
            'Median 2nd Effect' : format(np.median(theta[:, 1]), ".3f"),
            'Mean Direct S' : format(np.mean(S[:, 0, 0]), ".3f"),
            'Median Direct S' : format(np.median(S[:, 0, 0]), ".3f"),
            'Mean 2nd Effect S' : format(np.mean(S[:, 1, 1]), ".3f"),
            'Median 2nd Effect S' : format(np.median(S[:, 1, 1]), ".3f"),
            'Mean Covariance' : format(np.mean(S[:, 0, 1]), ".3f"),
            'Median Covariance' : format(np.median(S[:, 0, 1]), ".3f"),
            'Phenotypic Variance' : format(dfin[f'phvar_{cohort}'][0], ".3f")     
        },
        index = [0])
        
        df_sumstats = df_sumstats.append(df_sumstatsi, ignore_index = True)
        
    
    df_sumstats = df_sumstats.set_index('Dataset').transpose()
        
    return df_sumstats



def make_diagnostic_plots(df_dict, df_args, transformto, plot_prefix = ".",
                         REF_file = "/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.ALLELE_FREQUENCY.MAPFILE.HRC.chr1_22_X.LET.FLIPPED_ALLELE_1000G+UK10K.txt",
                         savefig = True):
    
    REF = pd.read_csv(REF_file, delim_whitespace = True)
    ref_map_file = "/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.RSMID.MAPFILE.HRC.chr1_22_X.txt"
    REF_map = pd.read_csv(ref_map_file, delim_whitespace = True)
    REF_map['ChrPosID'] = REF_map['chr'].astype(str) + ':' + REF_map['pos'].astype(str)
    REF = REF.merge(REF_map, on = "ChrPosID")
    
    for cohort in df_dict:
        
        df_arg = df_args[cohort]
        
        # process data
        df_in = df_dict[cohort]
        df_merged = df_in.merge(REF, left_on = "SNP", right_on = "rsmid",
                       how = "left")
        
        # calculating f outliers
        df_merged['f_outlier'] = (np.abs(df_merged[f'f_{cohort}'] - df_merged['freq1']) > 0.2)
        n_f_outliters = df_merged['f_outlier'].sum()
        share_f_outliers = n_f_outliters/df_merged.shape[0]
        perc_f_outliers = format(share_f_outliers * 100, ".3f")
        
        theta = np.array(df_merged[f'theta_{cohort}'].tolist())
        S = np.array(df_merged[f'S_{cohort}'].tolist())
        S, theta = transform_estimates(df_arg['effect_transform'], transformto, S, theta)
        indir_effect_name = df_arg['effect_transform'].split('_')[-1]
        indir_effect_name = indir_effect_name.replace('_', ' ').title()
        
        # plotting
        fig, ax = plt.subplots(nrows = 3,
                              figsize = (8, 10))

        # AF Plot
        g = sns.scatterplot(df_merged['freq1'], df_merged[f'f_{cohort}'], alpha = 0.3,
                           ax = ax[0])
        g = sns.lineplot([0, 1], [0, 1], color = "black",
                        ax = ax[0])
        g.set_xlabel("Reference Frequency")
        g.set_ylabel("Sample Frequency")
        g.annotate(f'Number of outlier SNPS {n_f_outliters}', xy = (0.6, 0.2), xycoords='axes fraction')
        g.annotate(f'% outlier SNPS {perc_f_outliers}', xy = (0.6, 0.1), xycoords='axes fraction')
        g.set_title("AF Plot")
        
        # distribution of direct effects
        g = sns.distplot(theta[:,0], ax = ax[1])
        g.set_xlabel("Direct Effect")
        g.set_title("Distribution of Direct Effects")
        
        # distribution of 2nd effect
        g = sns.distplot(theta[:,1], ax = ax[2])
        g.set_xlabel(f"{indir_effect_name}")
        g.set_title(f"Distribution of {indir_effect_name} Effects")
        
        fig.tight_layout()
        
        if savefig:
            plt.savefig(plot_prefix + cohort + ".png")
        else:
            plt.show()
        
        print("Outputted plot!")
        
        
if __name__ == '__main__':
    # parse arguments
    parser=argparse.ArgumentParser()
    parser.add_argument('path2json', type=str, 
                        help='''Path to json file describing input
                        files''')
    parser.add_argument('--outprefix', type=str, help='''
    Location to output association statistic hdf5 file. 
    Outputs text output to outprefix.sumstats.gz and HDF5 
    output to outprefix.sumstats.hdf5''', default='')
    parser.add_argument('--transformto', type=str, help='''
    What the estimates should be transformed into''', default='direct_averageparental')
    args=parser.parse_args()

    startTime = dt.datetime.now()
    print(f'Start time: {startTime}')
    
    # reading in files
    with open(args.path2json) as f:
        data_args = json.load(f)
    
    # parsing
    df_dict, _ = read_from_json(data_args)

    print("Running diagnostics on input files...")
    dfdiag = print_sumstats(df_dict, data_args, args.transformto)
    dfdiag.to_csv(args.outprefix + ".diag.sumstats.csv")
    make_diagnostic_plots(df_dict, data_args, args.transformto, args.outprefix)
