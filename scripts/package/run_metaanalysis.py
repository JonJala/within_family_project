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
        A = np.array([[1.0, 0.0, 0.0],[0.0, 0.5, 0.5]])
    elif (dataeffect == "population") and (targeteffect == "direct_paternal_materal"):
        A = np.array([[1.0, 0.5, 0.5]])
    elif (dataeffect == "direct_population") and (targeteffect == "direct_population"):
        A = np.eye(2)

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

    startTime = dt.datetime.now()
    print(f'Start time: {startTime}')
    

    # reading in files
    with open(args.path2json) as f:
        data_args = json.load(f)
    
    # parsing
    data_args = process_json_args(data_args)
    df_merged, Amat_dicts = read_from_json(data_args, args)
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

    
    # df_merged = df_merged.sort_values(["CHR", "BP"]).reset_index(drop = True)

    # dims = df_merged['max_dim'].unique()
    # dims = dims[dims > 1] # we dont care about SNPs where we only have population effects
    df_out_list = []
    df_merged = (
        df_merged
        .pipe(highest_effect)
    )
    dims = df_merged['effect_identified'].unique()
    if "population" in dims:
        dims.remove("population")


    # arrays to store
    theta_tosave = np.empty(shape = (0, 5))
    theta_ses_tosave = np.empty(shape = (0, 5))
    theta_var_tosave = np.empty(shape = (0, 5, 5))

    f_tosave = np.empty(shape = (0, 1))

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
        Amat_check = Amat_dicts[dim]

        print("=================")
        print("Amat calculated")
        print(Amat)
        print("Amat Provided")
        print(Amat_check)
        print("=================")


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

        # combining everything into a dataframe
        df_out = pd.DataFrame(
            {
                'cptid' : df_toarray_dim['cptid'],
                'CHR' :  df_toarray_dim['CHR'].astype(int),
                'BP' :  df_toarray_dim['BP'],
                'SNP' :  df_toarray_dim['SNP'],
                'freq' : f_bar,
                'A1' : df_toarray_dim['A1'],
                'A2' : df_toarray_dim['A2'],
                'dir_N' : Neff_dir,
                'population_N' : Neff_pop,
                'dir_Beta' : theta_bar_out[:, 0].flatten(),
                'paternal_Beta' : theta_bar_out[:, 1].flatten(),
                'maternal_Beta' : theta_bar_out[:, 2].flatten(),
                'avgparental_Beta' : theta_bar_out[:, 3].flatten(),
                'population_Beta' : theta_bar_out[:, 4].flatten(),
                'dir_z' : z_bar_out[:, 0].flatten(),
                'paternal_z' : z_bar_out[:, 1].flatten(),
                'maternal_z' : z_bar_out[:, 2].flatten(),
                'avgparental_z' : z_bar_out[:, 3].flatten(),
                'population_z' : z_bar_out[:, 4].flatten(),
                'dir_SE' : theta_ses_out[:, 0],
                'paternal_SE' : theta_ses_out[:, 1],
                'maternal_SE' : theta_ses_out[:, 2],
                'avgparental_SE' : theta_ses_out[:, 3],
                'population_SE' : theta_ses_out[:, 4],
                'dir_paternal_rg': get_rg(theta_var_out[:, 0, 1], theta_ses_out[:, 0], theta_ses_out[:, 1]),
                'dir_maternal_rg': get_rg(theta_var_out[:, 0, 2], theta_ses_out[:, 0], theta_ses_out[:, 2]),
                'dir_avgparental_rg': get_rg(theta_var_out[:, 0, 3], theta_ses_out[:, 0], theta_ses_out[:, 3]),
                'dir_population_rg': get_rg(theta_var_out[:, 0, 4], theta_ses_out[:, 0], theta_ses_out[:, 4]),
                'paternal_maternal_rg': get_rg(theta_var_out[:, 1, 2], theta_ses_out[:, 1], theta_ses_out[:, 2]),
                'paternal_avgparental_rg': get_rg(theta_var_out[:, 1, 3], theta_ses_out[:, 1], theta_ses_out[:, 3]),
                'paternal_population_rg': get_rg(theta_var_out[:, 1, 4], theta_ses_out[:, 1], theta_ses_out[:, 4]),
                'maternal_avgparental_rg': get_rg(theta_var_out[:, 2, 3], theta_ses_out[:, 2], theta_ses_out[:, 3]),
                'maternal_population_rg': get_rg(theta_var_out[:, 2, 4], theta_ses_out[:, 2], theta_ses_out[:, 4]),
                'avgparental_population_rg': get_rg(theta_var_out[:, 3, 4], theta_ses_out[:, 3], theta_ses_out[:, 4]),
                'dir_pval' : pval_out[:, 0].flatten(),
                'paternal_pval' : pval_out[:, 1].flatten(),
                'maternal_pval' : pval_out[:, 2].flatten(),
                'avgparental_pval' : pval_out[:, 3].flatten(),
                'population_pval' : pval_out[:, 4].flatten(),
                'n_cohorts' : df_toarray_dim['n_cohorts']
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
            df_out['CHR'],
            df_out['SNP'],
            df_out['BP'],
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
        df_out = df_out.sort_values(by = ["CHR", "BP"])
        print(f"Writing output to {args.outprefix + '.csv'}")
        df_out.to_csv(args.outprefix + '.csv', sep = '\t', index = False, na_rep = "nan")
    
    print(f"Median direct-population effect correlation: {np.median(df_out['dir_population_rg'])}")
    endTime = dt.datetime.now()
    print(f'End time: {endTime}')
    print(f'Script took {endTime - startTime} to complete.')
    
    
    
    
        
    
    
    
    