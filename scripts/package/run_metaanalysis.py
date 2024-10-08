import numpy as np
import pandas as pd
import datetime as dt
import json
import argparse

from parsedata import *
from metaanalysis import *

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

    for c in json_args:
        if 'bim' not in json_args[c]:
            json_args[c]['bim'] = 'bim'
        
        if 'bim_chromosome' not in json_args[c]:
            json_args[c]['bim_chromosome'] = 0
        else:
            json_args[c]['bim_chromosome'] = int(json_args[c]['bim_chromosome'])
        
        if 'bim_bp' not in json_args[c]:
            json_args[c]['bim_bp'] = 2
        else:
            json_args[c]['bim_bp'] = int(json_args[c]['bim_bp'])

        if 'bim_rsid' not in json_args[c]:
            json_args[c]['bim_rsid'] = 0
        else:
            json_args[c]['bim_rsid'] = int(json_args[c]['bim_rsid'])

        if 'a1' not in json_args[c]:
            json_args[c]['a1'] = 3
        else:
            json_args[c]['a1'] = int(json_args[c]['a1'])

        if 'a2' not in json_args[c]:
            json_args[c]['a2'] = 4
        else:
            json_args[c]['a2'] = int(json_args[c]['a2'])

        if 'bim_estimate' not in json_args[c]:
            json_args[c]['bim_estimate'] = 'estimate'

        if 'estimate_ses' not in json_args[c]:
            json_args[c]['estimate_ses'] = 'estimate_ses'

        if 'estimate_covariance' not in json_args[c]:
            json_args[c]['estimate_covariance'] = 'estimate_covariance'

        if 'sigma2' not in json_args[c]:
            json_args[c]['sigma2'] = 'sigma2'

        if 'tau' not in json_args[c]:
            json_args[c]['tau'] = 'tau'

        if 'freqs' not in json_args[c]:
            json_args[c]['freqs'] = 'freqs'

        if 'phvar' not in json_args[c]:
            json_args[c]['phvar'] = 1.0
        else:
            json_args[c]['phvar'] = float(json_args[c]['phvar'])

    return json_args


def highest_effect(df, colname = 'effects'):

    '''
    Looks at all the effects identified per SNP
    Then takes the 'highest' one. highest is defined by this
    hierarchy

    direct_paternal_maternal > direct_avgparental = direct_population > population
    '''

    effectmap = {
        'direct_paternal_maternal' : 3,
        'direct_maternal_paternal' : 3,
        'direct_population' : 2,
        'direct_avgparental' : 1,
        'population' : 0
    }

    revmap = {v: k for k, v in effectmap.items()}

    colnames = [c for c in df.columns if c.startswith(colname)]
    effects_ided = df[colnames].stack().map(effectmap).unstack()
    effects_ided = effects_ided.max(axis = 1)
    df['effect_identified'] = effects_ided.map(revmap)



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
        A = np.array([[1.0, 0.0, 0.0],[1.0, 0.5, 0.5]])
    elif (dataeffect == "population") and (targeteffect == "direct_paternal_maternal"):
        A = np.array([[1.0, 0.5, 0.5]])
    elif (dataeffect == "direct_population") and (targeteffect == "direct_population"):
        A = np.eye(2)
    elif (dataeffect == "population") and (targeteffect == "direct_population"):
        A = np.array([[0.0, 1.0]])

    return A

def getamat_dict(df, targeteffect):

    '''
    Identifies cohorts in data set, automatically determines
    what the appropriate A matrix should look like for each 
    and returns a dictionary
    '''

    theta_cols = [col for col in df.columns if col.startswith('theta_')]
    cohorts = [c[6:] for c in theta_cols]
    Amatdict = {}

    for idx, c in enumerate(cohorts):
        theta_vec_example = np.array(df[theta_cols[idx]][0])
        theta_vec_dim = theta_vec_example.shape[0]

        dataeffects = df[f'effects_{c}'].dropna().values
        dataeffect = dataeffects[0] if len(dataeffects) > 0 else ""

        if dataeffect == "":
            targeteffect_list = targeteffect.split("_")
            targeteffect_ndims = len(targeteffect_list)
            Amat = np.zeros((theta_vec_dim, targeteffect_ndims))
        else:
            Amat = getamat(dataeffect, targeteffect)

        Amatdict[c] = Amat
    
    return Amatdict

def process_args():

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
    parser.add_argument('--nohm3', action='store_false',dest='hm3', default = True,
    help = '''Do you want to not output a txt dataset with only hm3 snps.''')
    parser.add_argument('--nomediannfilter', action='store_false',dest='median_n_filter', default = True,
    help = '''Should median N cutoff be used. Default is 0.8 * median_effective_n (direct)''')
    parser.add_argument('--mediannthresh', dest='median_n_thresh', default = True,
    help = '''Should median N cutoff be used. Default is 0.8 * median_effective_n (direct)''')
    args=parser.parse_args()

    return args

def main(args):
    '''
    Run entire meta analysis
    '''

    startTime = dt.datetime.now()
    print(f'Start time: {startTime}')

    # reading in files
    with open(args.path2json) as f:
        data_args = json.load(f)
    
    # parsing
    data_args = process_json_args(data_args)
    df_merged = read_from_json(data_args, args)
    df_merged = merging_data(list(df_merged.values()), on_pos = args.on_pos)

    if args.on_pos:
        df_merged = df_merged.dropna(subset = ["cptid"])
    else:
        df_merged = df_merged.dropna(subset = ["SNP"])

    # get number of cohorts identified
    theta_cols = [c for c in df_merged if c.startswith('theta_')]
    df_merged['n_cohorts'] = (~df_merged[theta_cols].isna()).sum(axis = 1) 

    # creating data frame ready to become an array
    df_merged = (df_merged
        .pipe(begin_pipeline)
        .pipe(combine_cols, 'A1', [c for c in df_merged if c.startswith('A1_')])
        .pipe(combine_cols, 'A2', [c for c in df_merged if c.startswith('A2_')])
        )

    if args.on_pos:
        df_merged = (df_merged
        .pipe(begin_pipeline)
        .pipe(combine_cols, 'SNP', [c for c in df_merged if c.startswith('SNP_')])
        .pipe(combine_cols, 'CHR', [c for c in df_merged if c.startswith('CHR_')], 0)
        .pipe(combine_cols, 'BP', [c for c in df_merged if c.startswith('BP_')])
        .pipe(highest_dim)
        .pipe(highest_effect)
        )
    else:
        df_merged = (df_merged
        .pipe(begin_pipeline)
        .pipe(combine_cols, 'CHR', [c for c in df_merged if c.startswith('CHR_')], 0)
        .pipe(combine_cols, 'BP', [c for c in df_merged if c.startswith('BP_')])
        .pipe(combine_cols, 'cptid', [c for c in df_merged if c.startswith('cptid_')])
        .pipe(highest_dim)
        .pipe(highest_effect)
        )

    df_out_list = []
    df_merged = (
        df_merged
        .pipe(highest_effect)
    )

    
    dims = df_merged['effect_identified'].unique().tolist()
    if "population" in dims:
        dims.remove("population")


    # arrays to store
    theta_tosave = np.empty(shape = (0, 5))
    theta_ses_tosave = np.empty(shape = (0, 5))
    theta_var_tosave = np.empty(shape = (0, 5, 5))

    f_tosave = np.empty(shape = (0, 1))


    ## inv var weighted meta-analysis for direct effects only

    df_theta = df_merged.filter(regex = 'theta_') # df of effect estimates
    df_se = df_merged.filter(regex = 'se_') # df of standard errors

    df_theta = df_theta.applymap(lambda x: x[0] if isinstance(x, list) else x) # extract direct effect only
    df_se = df_se.applymap(lambda x: x[0] if isinstance(x, list) else x) # extract direct effect SE

    # rename columns so they align even though this is a bit janky
    df_se.columns = df_theta.columns

    # inverse variance weighted meta-analysis
    weights = 1 / df_se**2
    weighted_effects = df_theta * weights
    sum_weights = weights.sum(axis=1, skipna=True)
    sum_weighted_effects = weighted_effects.sum(axis=1, skipna=True)
    inv_var_direct_effect = sum_weighted_effects / sum_weights
    inv_var_direct_effect_se = np.sqrt(1 / sum_weights)

    inv_var_meta = pd.DataFrame({
        'cptid': df_merged['cptid'],
        'direct_effect_univariate': inv_var_direct_effect,
        'direct_effect_SE_univariate': inv_var_direct_effect_se
    })

    ## regular meta-analysis

    for dim in dims:

        print(f"Meta analyzing SNPs with effect dimensions {dim}...")
        df_toarray_dim = df_merged.loc[df_merged['effect_identified'] == dim].reset_index(drop = True)

        # properly formatting missing values
        df_toarray_dim = (
            df_toarray_dim
            .pipe(begin_pipeline)
            .pipe(make_array_cols_nas, 'theta_', 0)
            .pipe(make_array_cols_nas, 'S_', 1)
        )
        
        Amat = getamat_dict(df_toarray_dim, dim)

        print("=================")
        print("Amat calculated:")
        print(Amat)
        print("=================")


        # == Array operations == #
        theta_vec = extract_vector(df_toarray_dim, "theta")
        S_vec = extract_vector(df_toarray_dim, "S_")
        phvar_vec = extract_vector(df_toarray_dim, "phvar")
        phvar_vec = get_firstvalue_dict(phvar_vec)

        theta_vec_adj = adjust_theta_by_phvar(theta_vec, phvar_vec) ## by default, phvar is set to 1, and so no standardizing actually occurs here
        S_vec_adj = adjust_S_by_phvar(S_vec, phvar_vec) ## by default, phvar is set to 1, and so no standardizing actually occurs here
        
        wt = get_wts(Amat, S_vec_adj)
        nan_to_num_dict(wt, theta_vec_adj)
        
        # run analysis
        theta_bar, theta_var = get_estimates(theta_vec_adj, wt, Amat)
        
        # convert effects
        theta_var_out, theta_bar_out = transform_estimates(dim,
                                                "full_averageparental_population", 
                                                theta_var, 
                                                theta_bar.reshape(theta_bar.shape[0], 
                                                                    theta_bar.shape[1]))

        
        
        theta_ses_out = get_ses(theta_var_out)
        z_bar_out = theta2z(theta_bar_out, theta_var_out)
        pval_out = get_pval(z_bar_out)

        # computing weighted f
        f_vec = extract_vector(df_toarray_dim, "f_")
        nan_to_num_dict(f_vec)
        wt_dir = extract_portion(wt, 0)
        f_bar = freq_wted_sum(f_vec, wt_dir)
        wt_dir_sum = get_wt_sum(wt_dir)
        f_bar = f_bar/wt_dir_sum
        
        Neff_dir = neff(f_bar, theta_ses_out[:, 0])
        Neff_pop = neff(f_bar, theta_ses_out[:, 4])
        Neff_avg_ntc = neff(f_bar, theta_ses_out[:, 3])

        # combining everything into a dataframe
        df_out = pd.DataFrame(
            {
                'cptid' : df_toarray_dim['cptid'],
                'chromosome' :  df_toarray_dim['CHR'].astype(int),
                'pos' :  df_toarray_dim['BP'].astype(int),
                'SNP' :  df_toarray_dim['SNP'],
                'freq' : f_bar,
                'A1' : df_toarray_dim['A1'],
                'A2' : df_toarray_dim['A2'],
                'direct_N' : Neff_dir.astype(int),
                'population_N' : Neff_pop.astype(int),
                'avg_NTC_N' : Neff_avg_ntc.astype(int),
                'direct_Beta' : theta_bar_out[:, 0].flatten(),
                'paternal_Beta' : theta_bar_out[:, 1].flatten(),
                'maternal_Beta' : theta_bar_out[:, 2].flatten(),
                'avg_NTC_Beta' : theta_bar_out[:, 3].flatten(),
                'population_Beta' : theta_bar_out[:, 4].flatten(),
                'direct_Z' : z_bar_out[:, 0].flatten(),
                'paternal_Z' : z_bar_out[:, 1].flatten(),
                'maternal_Z' : z_bar_out[:, 2].flatten(),
                'avg_NTC_Z' : z_bar_out[:, 3].flatten(),
                'population_Z' : z_bar_out[:, 4].flatten(),
                'direct_SE' : theta_ses_out[:, 0],
                'paternal_SE' : theta_ses_out[:, 1],
                'maternal_SE' : theta_ses_out[:, 2],
                'avg_NTC_SE' : theta_ses_out[:, 3],
                'population_SE' : theta_ses_out[:, 4],
                'r_direct_paternal': get_rg(theta_var_out[:, 0, 1], theta_ses_out[:, 0], theta_ses_out[:, 1]),
                'r_direct_maternal': get_rg(theta_var_out[:, 0, 2], theta_ses_out[:, 0], theta_ses_out[:, 2]),
                'r_direct_avg_NTC': get_rg(theta_var_out[:, 0, 3], theta_ses_out[:, 0], theta_ses_out[:, 3]),
                'r_direct_population': get_rg(theta_var_out[:, 0, 4], theta_ses_out[:, 0], theta_ses_out[:, 4]),
                'r_paternal_maternal': get_rg(theta_var_out[:, 1, 2], theta_ses_out[:, 1], theta_ses_out[:, 2]),
                'r_paternal_avg_NTC': get_rg(theta_var_out[:, 1, 3], theta_ses_out[:, 1], theta_ses_out[:, 3]),
                'r_paternal_population': get_rg(theta_var_out[:, 1, 4], theta_ses_out[:, 1], theta_ses_out[:, 4]),
                'r_maternal_avg_NTC': get_rg(theta_var_out[:, 2, 3], theta_ses_out[:, 2], theta_ses_out[:, 3]),
                'r_maternal_population': get_rg(theta_var_out[:, 2, 4], theta_ses_out[:, 2], theta_ses_out[:, 4]),
                'r_avg_parental_population': get_rg(theta_var_out[:, 3, 4], theta_ses_out[:, 3], theta_ses_out[:, 4]),
                'direct_pval' : pval_out[:, 0].flatten(),
                'paternal_pval' : pval_out[:, 1].flatten(),
                'maternal_pval' : pval_out[:, 2].flatten(),
                'avg_NTC_pval' : pval_out[:, 3].flatten(),
                'population_pval' : pval_out[:, 4].flatten(),
                'n_cohorts' : df_toarray_dim['n_cohorts'].astype(int)
            }
        )

        n_missing_snps = df_out['cptid'].isna().sum()
        print(f"Number of missing SNPs {n_missing_snps}")


        (theta_var_out, z_bar_out, 
        theta_ses_out, theta_var_out,
        pval_out, f_bar, df_out) = clean_snps(theta_bar_out, z_bar_out, 
                                            theta_ses_out, theta_var_out,
                                            pval_out, f_bar,
                                            df = df_out, idname = ['cptid'])
        df_out = df_out.dropna(subset = ['cptid'])
        

        # appending data
        df_out_list += [df_out]
        theta_tosave = np.vstack((theta_tosave, theta_bar_out))
        theta_ses_tosave = np.vstack((theta_ses_tosave, theta_ses_out))
        theta_var_tosave = np.vstack((theta_var_tosave, theta_var_out))

        f_tosave = np.vstack((f_tosave, f_bar[..., None]))


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
            args.outprefix,
            theta_tosave,
            theta_ses_tosave,
            theta_var_tosave,
            0.5,
            1.0,
            f_tosave.flatten()
        )
    
    
    if not args.no_txt_out:

        if args.hm3:
            hm3dat = pd.read_csv('/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist', delim_whitespace=True)
            df_out_hm3 = df_out[df_out['SNP'].isin(hm3dat.SNP)]
            df_out_hm3 = df_out_hm3.sort_values(by = ['chromosome', 'pos'])
            df_out_hm3.to_csv(args.outprefix + '.hm3.sumstats.gz', sep = ' ', index = False, na_rep = "nan")
            print(f"Median direct-population effect correlation HM3: {np.median(df_out_hm3['r_direct_population'])}")
            print(f"Median Direct N HM3: {np.median(df_out_hm3['direct_N'])}")
            print(f"Median Population N HM3: {np.median(df_out_hm3['population_N'])}")

        if args.median_n_filter:
            df_out_nfilter = df_out.loc[df_out['direct_N'] > args.median_n_thresh * df_out['direct_N'].median(), :]
            df_out_nfilter = df_out_nfilter.sort_values(by = ["chromosome", "pos"])
            print(f"Writing output to {args.outprefix + '.nfilter.sumstats.gz'}")
            df_out_nfilter.to_csv(args.outprefix + '.nfilter.sumstats.gz', sep = ' ', index = False, na_rep = "nan")

        df_out = df_out.sort_values(by = ["chromosome", "pos"])
        df_out.drop(columns = ['avg_NTC_N'], inplace = True)
        print(f"Writing output to {args.outprefix + '.sumstats.gz'}")
        df_out.to_csv(args.outprefix + '.sumstats.gz', sep = ' ', index = False, na_rep = "nan")

        ## version for public release

        # merge with univariate direct effects
        df_out = df_out.merge(inv_var_meta, on = 'cptid', how = 'left')
        df_out['direct_N_univariate'] = np.round((2*df_out['freq']*(1-df_out['freq'])*df_out['direct_effect_SE_univariate']**2)**(-1))
        
        # round freq to 3 dp
        df_out['freq'] = df_out['freq'].round(3)
        
        # rename col
        df_out.rename(columns = {'r_avg_parental_population' : 'r_avg_NTC_population'}, inplace = True)

        # reorder cols
        colnames = ['cptid', 'chromosome', 'pos', 'SNP', 'freq', 'A1', 'A2', 'direct_N', 'direct_Beta', 'direct_SE', 'direct_Z', 'direct_pval', 'paternal_Beta', 'paternal_SE', 'paternal_Z', 'paternal_pval', 'maternal_Beta', 'maternal_SE', 'maternal_Z', 'maternal_pval', 'avg_NTC_Beta', 'avg_NTC_SE', 'avg_NTC_Z', 'avg_NTC_pval', 'population_N', 'population_Beta', 'population_SE', 'population_Z', 'population_pval', 'direct_N_univariate', 'direct_effect_univariate', 'direct_effect_SE_univariate', 'r_direct_paternal', 'r_direct_maternal', 'r_direct_avg_NTC', 'r_direct_population', 'r_paternal_maternal', 'r_paternal_avg_NTC', 'r_paternal_population', 'r_maternal_avg_NTC', 'r_maternal_population', 'r_avg_NTC_population', 'n_cohorts']
        df_out = df_out[colnames]

        # save
        df_out.to_csv(args.outprefix + '.pub.release.sumstats.gz', sep = ' ', index = False, na_rep = "nan")

    print(f"Median direct-population effect correlation: {np.median(df_out['r_direct_population'])}")
    print(f"Median Direct N: {np.median(df_out['direct_N'])}")
    print(f"Median Population N: {np.median(df_out['population_N'])}")
    endTime = dt.datetime.now()
    print(f'End time: {endTime}')
    print(f'Script took {endTime - startTime} to complete.')


if __name__ == '__main__':
    
    args = process_args()
    main(args)