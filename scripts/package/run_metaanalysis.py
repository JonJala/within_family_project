import numpy as np
import pandas as pd
import datetime as dt
import json
import argparse

from parsedata import *
from metaanalysis import *
from diagnostics import *


if __name__ == '__main__':
    
    
    # parse arguments
    parser=argparse.ArgumentParser()
    parser.add_argument('path2json', type=str, 
                        help='''Path to json file describing input
                        files''')
    parser.add_argument('--outestimates', type=str, 
                        help='''What format should the out estimates be. By default it doesnt transform the
                        final estimates but you can transform it to direct_plus_population, or direct_plus_averageparental''',
                       default = "full")
    parser.add_argument('--outprefix', type=str, help='''
    Location to output association statistic hdf5 file. 
    Outputs text output to outprefix.sumstats.gz and HDF5 
    output to outprefix.sumstats.hdf5''', default='')
    parser.add_argument('--no_hdf5_out',action='store_true',help='Suppress HDF5 output of summary statistics',default=False)
    parser.add_argument('--no_txt_out',action='store_true',help='Suppress text output of summary statistics',default=False)
    parser.add_argument('--diag',action='store_true',help='Produce diagnostic plots and summary statistics of input files.',default=False)
    args=parser.parse_args()
    

    startTime = dt.datetime.now()
    print(f'Start time: {startTime}')
    
    # reading in files
    with open(args.path2json) as f:
        data_args = json.load(f)
    
    # parsing
    df_dict = read_from_json(data_args)

    if args.diag:
        print("Running diagnostics on input files...")
        dfdiag = print_sumstats(df_dict, data_args)
        dfdiag.to_csv(args.outprefix + ".sumstats.csv")
        make_diagnostic_plots(df_dict, data_args, args.outprefix)
    df_merged = merging_data(list(df_dict.values()))

    # Filtering and aligning alleles/effects
    allele_cols = [col for col in df_merged if col.startswith('alleles')]
    df_merged['allele_consensus'] = df_fastmode(df_merged, allele_cols)
    df_merged = df_merged.dropna(subset = ["SNP"])
    df_merged = allele_plus_alleleconsensus(df_merged, allele_cols)
    df_toarray = filter_and_align(df_merged, list(data_args.keys()))

    # creating data frame ready to become an array
    df_toarray = (df_toarray
    .pipe(begin_pipeline)
    .pipe(combine_cols, 'CHR', [c for c in df_toarray if c.startswith('CHR_')], 0)
    .pipe(combine_cols, 'BP', [c for c in df_toarray if c.startswith('BP_')])
    )
    
    df_toarray = df_toarray.sort_values("BP").reset_index(drop = True)
    
    
    # == Array operations == #
    theta_vec = extract_vector(df_toarray, "theta")
    S_vec = extract_vector(df_toarray, "S_")
    phvar_vec = extract_vector(df_toarray, "phvar")
    phvar_vec = get_firstvalue_dict(phvar_vec)

    
    Amat = extract_vector(df_toarray, "amat")
    Amat = get_firstvalue_dict(Amat)

    theta_vec_adj, S_vec_adj  = transform_estimates_dict(theta_vec, S_vec, data_args)
    theta_vec_adj = adjust_theta_by_phvar(theta_vec_adj, phvar_vec)
    S_vec_adj = adjust_S_by_phvar(S_vec_adj, phvar_vec)
    
    wt = get_wts(S_vec_adj)
    nan_to_num_dict(wt, theta_vec_adj)
    
    # run analysis
    theta_bar, theta_var, wt_sum = get_estimates(theta_vec_adj, wt)
    theta_ses = get_ses(theta_var)
    z_bar = theta2z(theta_bar, theta_var)
    pval = get_pval(z_bar)

    theta_var_out, theta_bar_out = transform_estimates(args.outestimates, 
                                                   theta_var, 
                                                   theta_bar.reshape(theta_bar.shape[0], 
                                                                     theta_bar.shape[1]))
    theta_ses_out = get_ses(theta_var_out)
    z_bar_out = theta2z(theta_bar_out, theta_var_out)
    pval_out = get_pval(z_bar_out)
    
    
    # computing weighted f
    f_vec = extract_vector(df_toarray, "f_")
    nan_to_num_dict(f_vec)
    wt_dir = extract_portion(wt, 0)
    f_bar = freq_wted_sum(f_vec, wt_dir)
    wt_dir_sum = get_wt_sum(wt_dir)
    f_bar = f_bar/wt_dir_sum

    # preparation for outdata
    est1_type = args.outestimates.split("_")[0]
    est2_type = args.outestimates.split("_")[-1]
    
    Neff_dir = neff(f_bar, theta_ses_out[:, 0])
    Neff_effect1 = neff(f_bar, theta_ses[:, 1])
    Neff_effect2 = neff(f_bar, theta_ses_out[:, 1])
    
    # combining everything into a dataframe
    df_out = pd.DataFrame(
        {
            'SNP' : df_toarray['SNP'],
            'BP' : df_toarray['BP'].astype(int),
            'CHR' : df_toarray['CHR'].astype(int),
            'allele_comb' : df_toarray['allele_consensus'],
            'beta_dir' : theta_bar_out[:, 0].flatten(),
            f'beta_{est1_type}' : theta_bar[:, 1].flatten(),
            f'beta_{est2_type}' : theta_bar_out[:, 1].flatten(),
            'wt_dir' : wt_sum[:, 0, 0],
            'wt_2' : wt_sum[:, 1, 1],
            'N_dir' : Neff_dir,
            f'N_{est1_type}' : Neff_effect1,
            f'N_{est2_type}' : Neff_effect2,
            'z_dir' : z_bar_out[:, 0].flatten(),
            f'z_{est1_type}' : z_bar[:, 1].flatten(),
            f'z_{est2_type}' : z_bar_out[:, 1].flatten(),
            'beta_se_dir' : theta_ses_out[:, 0],
            f'beta_se_{est1_type}' : theta_ses[:, 1],
            f'beta_se_{est2_type}' : theta_ses_out[:, 1],
            f'beta_cov_{est1_type}': theta_var[:, 0, 1],
            f'beta_cov_{est2_type}': theta_var_out[:, 0, 1],
            'pval_dir' : pval_out[:, 0].flatten(),
            f'pval_{est1_type}' : pval[:, 1].flatten(),
            f'pval_{est2_type}' : pval_out[:, 1].flatten(),
            'f' : f_bar
        }
    )

    df_out[['Allele1', 'Allele2']] = df_out['allele_comb'].str.split("", expand = True)[[1, 2]]
    df_out = df_out.drop(columns = "allele_comb")

    n_missing_snps = df_out['SNP'].isna().sum()
    print(f"Number of missing SNPs {n_missing_snps}")
    (theta_bar, theta_var_out, wt_sum, z_bar, z_bar_out, 
    theta_ses, theta_ses_out, theta_var, theta_var_out,
    pval, pval_out, f_bar, df_out) = clean_snps(theta_bar, theta_bar_out, wt_sum, z_bar, z_bar_out, 
                                        theta_ses, theta_ses_out, theta_var, theta_var_out,
                                        pval, pval_out, f_bar,
                                        df = df_out, snpname = 'SNP')
    df_out = df_out.dropna(subset = ['SNP'])
    
    # == Outputting data == #

    if not args.no_txt_out:
        df_out.to_csv(args.outprefix + '.csv', sep = ' ', index = False, na_rep = ".")
    
    if not args.no_hdf5_out:
        write_output(
            df_out['CHR'],
            df_out['SNP'],
            df_out['BP'],
            df_out[['Allele1', 'Allele2']],
            args.outprefix  + '_' + est1_type,
            theta_bar.reshape(theta_bar_out.shape),
            theta_ses,
            theta_var,
            0.0,
            0.0,
            f_bar
        )

        write_output(
            df_out['CHR'],
            df_out['SNP'],
            df_out['BP'],
            df_out[['Allele1', 'Allele2']],
            args.outprefix + '_' + est2_type,
            theta_bar_out.reshape(theta_bar_out.shape),
            theta_ses_out,
            theta_var_out,
            0.0,
            0.0,
            f_bar
        )
    
    

    print(f'Median sampling correlation: {np.median(theta_var_out[:, 0 ,1]/(theta_ses_out[:, 0] * theta_ses_out[:, 1]))}')
    endTime = dt.datetime.now()
    print(f'End time: {endTime}')

    print(f'Script took {endTime - startTime} to complete.')
    
    
    
    
        
    
    
    
    