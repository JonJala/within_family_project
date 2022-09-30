import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import argparse
import datetime as dt
import json
from scipy.stats import beta, chi2

import matplotlib as mpl
from matplotlib import lines
mpl.rcParams['agg.path.chunksize'] = 10000

from parsedata import *
from metaanalysis import *


def print_sumstats(df_dict, df_args, 
                    args, 
                    transformto, 
                    hm3path = "/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist"):
    
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

        if args.on_pos:
            dfin = (dfin
            .pipe(begin_pipeline)
            .pipe(combine_cols, 'SNP', [c for c in dfin if c.startswith('SNP_')])
            )

        # filtering hm3
        ii = np.array([True for i in range(len(dfin))])
        ii = dfin['SNP'].isin(hm3['SNP'])
        if ii.sum() == 0:
            print(f"Number of SNPs after subsetting to HM3: {ii.sum()}")
        dfout = dfin[ii].reset_index(drop=True)

        theta = np.array(dfin[f'theta_{cohort}'].tolist())
        S = np.array(dfin[f'S_{cohort}'].tolist())
        S, theta = transform_estimates(df_arg['effect_transform'], transformto, S, theta)
        indir_effect_name = df_arg['effect_transform'].split('_')[-1]
        print(f'Second effect is: {indir_effect_name}')

        
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



def make_af_plot(df_dict, args, plot_prefix = ".",
                REF_file = "/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.ALLELE_FREQUENCY.MAPFILE.HRC.chr1_22_X.LET.FLIPPED_ALLELE_1000G+UK10K.txt",
                ref_map_file = "/var/genetics/ukb/linner/EA3/EasyQC_HRC/EASYQC.RSMID.MAPFILE.HRC.chr1_22_X.txt",
                savefig = True):
    
    REF = pd.read_csv(REF_file, delim_whitespace = True)
    REF_map = pd.read_csv(ref_map_file, delim_whitespace = True)
    REF_map['ChrPosID'] = REF_map['chr'].astype(str) + ':' + REF_map['pos'].astype(str)
    REF = REF.merge(REF_map, on = "ChrPosID")
    
    for cohort in df_dict:
        
        # process data
        df_in = df_dict[cohort]
        if args.on_pos:
            df_in = (df_in
            .pipe(begin_pipeline)
            .pipe(combine_cols, 'SNP', [c for c in df_in if c.startswith('SNP_')])
            )

        df_merged = df_in.merge(REF, left_on = "SNP", right_on = "rsmid",
                       how = "left")
        
        # calculating f outliers
        df_merged['f_outlier'] = (np.abs(df_merged[f'f_{cohort}'] - df_merged['freq1']) > 0.2)
        n_f_outliters = df_merged['f_outlier'].sum()
        share_f_outliers = n_f_outliters/df_merged.shape[0]
        perc_f_outliers = format(share_f_outliers * 100, ".3f")

        
        # plotting
        fig, ax = plt.subplots(figsize = (8, 10))

        # AF Plot
        g = sns.scatterplot(df_merged['freq1'], df_merged[f'f_{cohort}'], alpha = 0.3,
                           ax = ax)
        g = sns.lineplot([0, 1], [0, 1], color = "black",
                        ax = ax)
        g.set_xlabel("Reference Frequency")
        g.set_ylabel("Sample Frequency")
        g.annotate(f'Number of outlier SNPS {n_f_outliters}', xy = (0.6, 0.2), xycoords='axes fraction')
        g.annotate(f'% outlier SNPS {perc_f_outliers}', xy = (0.6, 0.1), xycoords='axes fraction')
        g.set_title("AF Plot")
        
        if savefig:
            plotname = plot_prefix + '_af_' + cohort + ".png"
            plt.savefig(plotname)
            print(f"Outputted plot to {plotname}")
        else:
            plt.show()
        
        


def calc_minuslog10(pval):

    minuslog10pvalue = -np.log10(pval)
    return minuslog10pvalue


def create_theoretical_data(length):
    simulated = np.linspace(1./length, 1+1./length, length)
    theoretical = -np.log10(simulated)
    return theoretical

def calculate_lambdagc(z):
    """
    lambda_GC is the ratio of the median chi2 statistic in the data to
    median of chi2 statistic with 1 degree of freedom
    """
    input_chi2 = z**2
    return np.median(input_chi2)/chi2.median(1)


def make_qqplot(df_dict, df_args, 
                args, 
                transformto,
                plot_prefix = ".",
                hm3path = "/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist",
                savefig = True):

    hm3 = pd.read_csv(hm3path, delim_whitespace = True)

    for cohort in df_dict:
        
        dfin = df_dict[cohort]
        df_arg = df_args[cohort]

        if args.on_pos:
            dfin = (dfin
            .pipe(begin_pipeline)
            .pipe(combine_cols, 'SNP', [c for c in dfin if c.startswith('SNP_')])
            )

        # filtering hm3
        ii = np.array([True for i in range(len(dfin))])
        ii = dfin['SNP'].isin(hm3['SNP'])
        if ii.sum() == 0:
            print(f"Number of SNPs after subsetting to HM3: {ii.sum()}")

        
        theta = np.array(dfin[f'theta_{cohort}'].tolist())
        S = np.array(dfin[f'S_{cohort}'].tolist())
        S, theta = transform_estimates(df_arg['effect_transform'], transformto, S, theta)
        z = theta2z(theta, S)
        pval = get_pval(z)

        indir_effect_name = transformto.split('_')[-1]
        print(f'Second effect is: {indir_effect_name}')

        print('Making QQ-plot...')
        fig, ax = plt.subplots(figsize = (10, 5),
                                ncols = 2)

        # simulate and sort theoretical data
        theoretical = create_theoretical_data(pval.shape[0])
        theoretical = np.sort(theoretical)

        for idx, effect in enumerate(['Direct', indir_effect_name.title()]):

            print(effect)


            # calculate and sort empirical -log(p) values
            empirical = calc_minuslog10(pval[:, idx])
            empirical = np.sort(empirical)

            lambdaGC = calculate_lambdagc(z[:, idx])
            # format lambda GC as string with 2 decimals
            str_lambdaGC = '%.2f' %  lambdaGC
            print('Lambda_GC is ' + str_lambdaGC + '.')
            

            ax[idx].scatter(theoretical, empirical, 
                alpha = 0.8, color = '#8B0001',
                s = 2
                )
            # add to plot
            ypos = args.lambda_ypos * max(empirical)
            xpos = args.lambda_xpos * max(theoretical)
            ax[idx].text(xpos, ypos, 
                r'$\lambda_{GC} = $' + str_lambdaGC, \
                ha='center', \
                va='center', \
                fontsize=17)
            ax[idx].set_title(effect + " Effect")

            # add 45-degree line to plot
            x = np.linspace(*ax[idx].get_xlim())
            ax[idx].plot(x, x)

            # creating CI
            n = theoretical.shape[0]
            # calculate x values under null
            x_ci = -np.log10(np.linspace(1/n, 1, int(n)))
            # calculate CI using beta distribution
            a = np.arange(1, n+1) # shape 1
            b = a[len(a)::-1] # shape 2
            clower = -np.log10(beta.ppf((1 - 0.95) / 2, a, b)) # upper bound
            cupper = -np.log10(beta.ppf((1 + 0.95) / 2, a, b)) # lower bound
            # add to plot
            ax[idx].fill_between(x_ci, clower, cupper, color='k', alpha=.1)


        if savefig:
            plotname = plot_prefix + '_qq_' + cohort + ".png"
            plt.savefig(plotname)
            print(f"Outputted plot to {plotname}")
        else:
            plt.show()
        
        

        
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
    What the estimates should be transformed into''', default='direct_population')
    parser.add_argument('--on-rsid', action='store_false',dest='on_pos', default = True,
    help = '''Do you want to merge cohorts by rsid instead of default which is pos''')
    # lambda GC position
    parser.add_argument("--lambda_xpos", type=float, default=0.3, \
                        help='Position on x-axis of the lambda_GC as fraction. Defaults to 0.')
    parser.add_argument("--lambda_ypos", type=float, default=0.7, \
                        help='Position on y-axis of the lambda_GC as fraction. Defaults to 0.')
    args=parser.parse_args()

    startTime = dt.datetime.now()
    print(f'Start time: {startTime}')
    
    # reading in files
    with open(args.path2json) as f:
        data_args = json.load(f)
    
    # parsing
    df_dict, _ = read_from_json(data_args, args)

    print("Running diagnostics on input files...")
    dfdiag = print_sumstats(df_dict, data_args, args, args.transformto)
    dfdiag.to_csv(args.outprefix + ".diag.sumstats.csv")
    make_af_plot(df_dict, args, plot_prefix=args.outprefix)
    make_qqplot(df_dict, data_args, args, args.transformto, plot_prefix=args.outprefix)
