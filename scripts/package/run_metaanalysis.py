import numpy as np
import pandas as pd
import datetime as dt
import json
import argparse

from parsedata import *
from metaanalysis import *
from diagnostics import *

def process_json_args(json_args_in):

    '''
    Since individual data/cohort arguments
    are passed through a json file, we need a 
    way to set up defaults for it

    Here are the default values
    "bim_chromosome" : 0,
    "bim_bp" : 2,
    "bim_rsid" : 1,
    "bim_a1" : 3,
    "bim_a2" : 4,
    "estimate" : "estimate",
    "estimate_ses" : "estimate_ses",
    "estimate_covariance" : "estimate_covariance",
    "sigma2" : "sigma2",
    "tau" : "tau",
    "freqs" : "freqs"
    "phvar" : 1
    '''

    json_args = json_args_in.copy()

    if 'bim' not in json_args:
        json_args['bim'] == 'bim'
    
    if 'bim_chromosome' not in json_args:
        json_args['bim_chromosome'] = 0
    else:
        json_args['bim_chromosome'] = int(json_args['bim_chromosome'])
    
    if 'bim_bp' not in json_args:
        json_args['bim_bp'] = 2
    else:
        json_args['bim_bp'] = int(json_args['bim_bp'])

    if 'bim_rsid' not in json_args:
        json_args['bim_rsid'] = 0
    else:
        json_args['bim_rsid'] = int(json_args['bim_rsid'])

    if 'a1' not in json_args:
        json_args['a1'] = 3
    else:
        json_args['a1'] = int(json_args['a1'])

    if 'a2' not in json_args:
        json_args['a2'] = 4
    else:
        json_args['a2'] = int(json_args['a2'])

    if 'bim_estimate' not in json_args:
        json_args['bim_estimate'] = 'estimate'

    if 'estimate_ses' not in json_args:
        json_args['estimate_ses'] = 'estimate_ses'

    if 'estimate_covariance' not in json_args:
        json_args['estimate_covariance'] = 'estimate_covariance'

    if 'sigma2' not in json_args:
        json_args['sigma2'] = 'sigma2'

    if 'tau' not in json_args:
        json_args['tau'] = 'tau'

    if 'freqs' not in json_args:
        json_args['freqs'] = 'freqs'

    if 'phvar' not in json_args:
        json_args['phvar'] = 1.0
    else:
        json_args['phvar'] = float(json_args['phvar'])

    return json_args

def effect_hierarchy(effect_list):
    '''
    For a list return the 'highest' effect.

    Highest is defined by this
    hierarchy

    direct_paternal_maternal > direct_population > direct_avgparental > population
    '''

    if 'direct_paternal_maternal' in effect_list or 'direct_maternal_paternal' in effect_list:
        highest_effect = 'direct_paternal_maternal'
    elif 'direct_population' in effect_list:
        highest_effect = 'direct_population'
    elif 'direct_avgparental' in effect_list or 'direct_averageparental' in effect_list:
        highest_effect = 'direct_avgparental'
    elif 'population' in effect_list:
        highest_effect = 'population'
    else:
        highest_effect = "noeffect"

    return highest_effect

def highest_effect(df, colname = 'effects'):

    '''
    Looks at all the effects identified per SNP
    Then takes the 'highest' one. highest is defined by this
    hierarchy

    direct_paternal_maternal > direct_avgparental = direct_population > population
    '''

    colnames = [c for c in df.columns if c.startswith(colname)]
    df['effect_identified'] = df[colnames].apply(effect_hierarchy)

    return df

def highest_dim(df:pd.DataFrame, colname = 'dims') -> pd.DataFrame:

    colnames = [c for c in df.columns if c.startswith(colname)]
    df['max_dim'] = df[colnames].max(axis = 1)

    return df

def getamat(dataeffect, targeteffect):
    '''
    Constructs A matrix according to what
    effects the cohort has identified and
    what effect we want to identify
    '''

    if targeteffect == 'direct_maternal_paternal':
        targeteffect = 'direct_paternal_maternal'
    
    if dataeffect == 'direct_maternal_paternal':
        dataeffect = 'direct_paternal_maternal'

    if ((dataeffect == "direct_paternal_maternal") and 
    (targeteffect == "direct_paternal_maternal")):
        A = np.eye(3)
    elif (dataeffect == "direct_population") and (targeteffect == "direct_paternal_maternal"):
        A = np.array([[1.0, 0.0, 0.0],[0.0, 0.5, 0.5]])
    elif (dataeffect == "population") and (targeteffect == "direct_paternal_materal"):
        A = np.array([[1.0, 0.5, 0.5]])
    elif (dataeffect == "direct_population") and (targeteffect == "direct_population"):
        A = np.eye(2)

    return A


if __name__ == '__main__':
    
    
    # parse arguments
    parser=argparse.ArgumentParser()
    parser.add_argument('path2json', type=str, 
                        help='''Path to json file describing input
                        files''')
    parser.add_argument('--outestimates', type=str, 
                        help='''What format should the out estimates be. By default it doesnt transform the
                        final estimates but you can transform it to direct_plus_population, or direct_plus_averageparental''',
                       default = "direct_plus_population")
    parser.add_argument('--outprefix', type=str, help='''
    Location to output association statistic hdf5 file. 
    Outputs text output to outprefix.sumstats.gz and HDF5 
    output to outprefix.sumstats.hdf5''', default='')
    parser.add_argument('--no_hdf5_out',action='store_true',help='Suppress HDF5 output of summary statistics',default=False)
    parser.add_argument('--no_txt_out',action='store_true',help='Suppress text output of summary statistics',default=False)
    parser.add_argument('--on-rsid', action='store_false',dest='on_pos', default = True,
    help = '''Do you want to merge cohorts by rsid instead of default which is pos''')
    args=parser.parse_args()

    print(f"Merging on rsid: {not args.on_pos}")
    

    startTime = dt.datetime.now()
    print(f'Start time: {startTime}')
    
    # reading in files
    with open(args.path2json) as f:
        data_args = json.load(f)
    
    # parsing
    data_args = process_json_args(data_args)
    df_dict, Amat_dicts = read_from_json(data_args, args)

    df_merged = merging_data(list(df_dict.values()), on_pos = args.on_pos)
    if args.on_pos:
        df_merged = df_merged.dropna(subset = ["BP", "CHR"])
    else:
        df_merged = df_merged.dropna(subset = ["SNP"])

    # Filtering and aligning alleles/effects
    # may not be necessary anymore!
    allele_cols = [col for col in df_merged if col.startswith('alleles')]
    df_merged['allele_consensus'] = df_fastmode(df_merged, allele_cols)
    df_merged = allele_plus_alleleconsensus(df_merged, allele_cols)
    df_toarray = filter_and_align(df_merged, list(data_args.keys()))

    # creating data frame ready to become an array

    if args.on_pos:
        df_toarray = (df_toarray
        .pipe(begin_pipeline)
        .pipe(combine_cols, 'SNP', [c for c in df_toarray if c.startswith('SNP_')])
        .pipe(highest_dim)
        )
    else:
        df_toarray = (df_toarray
        .pipe(begin_pipeline)
        .pipe(combine_cols, 'CHR', [c for c in df_toarray if c.startswith('CHR_')], 0)
        .pipe(combine_cols, 'BP', [c for c in df_toarray if c.startswith('BP_')])
        .pipe(highest_dim)
        )

    
    df_toarray = df_toarray.sort_values(["CHR", "BP"]).reset_index(drop = True)


    dims = df_toarray['max_dim'].unique()
    dims = dims[dims > 1] # we dont care about SNPs where we only have population effects
    df_out_list = []

    # arrays to store
    theta_tosave = np.empty(shape = (0, 2))
    theta_ses_tosave = np.empty(shape = (0, 2))
    theta_var_tosave = np.empty(shape = (0, 2, 2))

    theta_bar_pop_tosave = np.empty(shape = (0, 2))
    theta_ses_pop_tosave = np.empty(shape = (0, 2))
    theta_var_pop_tosave = np.empty(shape = (0, 2, 2))

    f_bar_tosave = np.empty(shape = (0, 1))


    for dim in dims:

        print(f"Meta analyzing SNPs with effect dimensions {dim}...")

        df_toarray_dim = df_toarray.loc[df_toarray['max_dim'] == dim].reset_index(drop = True)
        Amat = Amat_dicts[str(int(dim))] # replace this with a simple a func which takes effect, and target effect. return Amat

        # properly formatting missing values
        df_toarray_dim = (
            df_toarray_dim
            .pipe(begin_pipeline)
            .pipe(make_array_cols_nas, 'theta_', Amat, 0)
            .pipe(make_array_cols_nas, 'S_', Amat)
        )

        # == Array operations == #
        theta_vec = extract_vector(df_toarray_dim, "theta")
        S_vec = extract_vector(df_toarray_dim, "S_")
        phvar_vec = extract_vector(df_toarray_dim, "phvar")
        
        
        phvar_vec = get_firstvalue_dict(phvar_vec)

        theta_vec_adj = adjust_theta_by_phvar(theta_vec, phvar_vec)
        S_vec_adj = adjust_S_by_phvar(S_vec, phvar_vec)
        
        wt = get_wts(Amat, S_vec_adj)
        nan_to_num_dict(wt, theta_vec_adj)
        
        # run analysis
        theta_bar, theta_var = get_estimates(theta_vec_adj, wt, Amat)
        
        # convert effects
        if dim == 3:
            theta_var, theta_bar = transform_estimates("full",
                                                        "direct_averageparental", 
                                                        theta_var, 
                                                        theta_bar.reshape(theta_bar.shape[0], 
                                                                            theta_bar.shape[1]))
            fromest = "direct_averageparental"
        elif dim == 2:
            fromest = "direct_averageparental"

        theta_var_out, theta_bar_out = transform_estimates(fromest,
                                                            args.outestimates, 
                                                            theta_var, 
                                                            theta_bar.reshape(theta_bar.shape[0], 
                                                                                theta_bar.shape[1]))
    
        theta_ses = get_ses(theta_var)
        theta_ses_out = get_ses(theta_var_out)

        z_bar = theta2z(theta_bar, theta_var)
        pval = get_pval(z_bar)
        z_bar_out = theta2z(theta_bar_out, theta_var_out)
        pval_out = get_pval(z_bar_out)
        
        
        # computing weighted f
        f_vec = extract_vector(df_toarray_dim, "f_")
        nan_to_num_dict(f_vec)
        wt_dir = extract_portion(wt, 0)
        f_bar = freq_wted_sum(f_vec, wt_dir)
        wt_dir_sum = get_wt_sum(wt_dir)
        f_bar = f_bar/wt_dir_sum

        # preparation for outdata
        est1_type = "avgparental"
        est2_type = args.outestimates.split("_")[-1]
        
        Neff_dir = neff(f_bar, theta_ses_out[:, 0])
        Neff_effect1 = neff(f_bar, theta_ses[:, 1])
        Neff_effect2 = neff(f_bar, theta_ses_out[:, 1])

        # combining everything into a dataframe
        df_out = pd.DataFrame(
            {
                'SNP' : df_toarray_dim['SNP'],
                'pos' : df_toarray_dim['BP'].astype(int),
                'chromosome' : df_toarray_dim['CHR'].astype(int),
                'freq' : f_bar,
                'allele_comb' : df_toarray_dim['allele_consensus'],
                'dir_Beta' : theta_bar_out[:, 0].flatten(),
                f'{est1_type}_Beta' : theta_bar[:, 1].flatten(),
                f'{est2_type}_Beta' : theta_bar_out[:, 1].flatten(),
                'dir_N' : Neff_dir,
                f'N_{est1_type}' : Neff_effect1,
                f'N_{est2_type}' : Neff_effect2,
                'z_dir' : z_bar_out[:, 0].flatten(),
                f'z_{est1_type}' : z_bar[:, 1].flatten(),
                f'z_{est2_type}' : z_bar_out[:, 1].flatten(),
                'dir_SE' : theta_ses_out[:, 0],
                f'{est1_type}_SE' : theta_ses[:, 1],
                f'{est2_type}_SE' : theta_ses_out[:, 1],
                f'dir_{est1_type}_Cov': theta_var[:, 0, 1],
                f'dir_{est2_type}_Cov': theta_var_out[:, 0, 1],
                'dir_pval' : pval_out[:, 0].flatten(),
                f'{est1_type}_pval' : pval[:, 1].flatten(),
                f'{est2_type}_pval' : pval_out[:, 1].flatten()
            }
        )

        df_out[['A1', 'A2']] = df_out['allele_comb'].str.split("", expand = True)[[1, 2]]
        df_out = df_out.drop(columns = "allele_comb")

        n_missing_snps = df_out['SNP'].isna().sum()
        print(f"Number of missing SNPs {n_missing_snps}")


        if not args.on_pos:
            (theta_bar, theta_var_out, z_bar, z_bar_out, 
            theta_ses, theta_ses_out, theta_var, theta_var_out,
            pval, pval_out, f_bar, df_out) = clean_snps(theta_bar, theta_bar_out, z_bar, z_bar_out, 
                                                theta_ses, theta_ses_out, theta_var, theta_var_out,
                                                pval, pval_out, f_bar,
                                                df = df_out, idname = 'SNP')
            df_out = df_out.dropna(subset = ['SNP'])
        else:
            (theta_bar, theta_var_out, z_bar, z_bar_out, 
            theta_ses, theta_ses_out, theta_var, theta_var_out,
            pval, pval_out, f_bar, df_out) = clean_snps(theta_bar, theta_bar_out, z_bar, z_bar_out, 
                                                theta_ses, theta_ses_out, theta_var, theta_var_out,
                                                pval, pval_out, f_bar,
                                                df = df_out, idname = ['pos', 'chromosome'])
            df_out = df_out.dropna(subset = ['pos', 'chromosome'])
        

        # appending data
        df_out_list += [df_out]

        theta_tosave = np.vstack((theta_tosave, theta_bar.reshape((theta_bar.shape[0], theta_bar.shape[1]))))
        theta_ses_tosave = np.vstack((theta_ses_tosave, theta_ses.reshape((theta_ses.shape[0], theta_ses.shape[1]))))
        theta_var_tosave = np.vstack((theta_var_tosave, theta_var.reshape((theta_var.shape[0], theta_var.shape[1], theta_var.shape[2]))))

        theta_bar_pop_tosave = np.vstack((theta_bar_pop_tosave, theta_bar_out.reshape((theta_bar.shape[0], theta_bar.shape[1]))))
        theta_ses_pop_tosave = np.vstack((theta_ses_pop_tosave, theta_ses_out.reshape((theta_ses_out.shape[0], theta_ses_out.shape[1]))))
        theta_var_pop_tosave = np.vstack((theta_var_pop_tosave, theta_var_out.reshape((theta_var_out.shape[0], theta_var_out.shape[1], theta_var_out.shape[2]))))

        f_bar_tosave = np.vstack((f_bar_tosave, f_bar[..., None]))


    # append list of dataframes
    df_out = pd.concat(df_out_list)
    print(f"Final output shape: {df_out.shape}")

    # == Outputting data == #
    
    if not args.no_hdf5_out:
        write_output(
            df_out['chromosome'],
            df_out['SNP'],
            df_out['pos'],
            df_out[['A1', 'A2']],
            args.outprefix  + '_' + est1_type,
            theta_tosave,
            theta_ses_tosave,
            theta_var_tosave,
            0.5,
            1.0,
            f_bar_tosave.flatten()
        )

        write_output(
            df_out['chromosome'],
            df_out['SNP'],
            df_out['pos'],
            df_out[['A1', 'A2']],
            args.outprefix + '_' + est2_type,
            theta_bar_pop_tosave,
            theta_ses_pop_tosave,
            theta_var_pop_tosave,
            0.5,
            1.0,
            f_bar_tosave.flatten()
        )
    
    
    if not args.no_txt_out:
        df_out = df_out.sort_values(by = ["chromosome", "pos"])
        print(f"Writing output to {args.outprefix + '.csv'}")
        df_out.to_csv(args.outprefix + '.csv', sep = ' ', index = False, na_rep = ".")
    

    print(f'Median sampling correlation: {np.median(theta_var_out[:, 0 ,1]/(theta_ses_out[:, 0] * theta_ses_out[:, 1]))}')
    endTime = dt.datetime.now()
    print(f'End time: {endTime}')

    print(f'Script took {endTime - startTime} to complete.')
    
    
    
    
        
    
    
    
    