import unittest
import numpy as np
import pandas as pd
from run_metaanalysis import *
import subprocess
import json
import os
import h5py

def correlation_from_covariance(covariance):

    v = np.sqrt(np.diag(covariance))
    outer_v = np.outer(v, v)
    correlation = covariance / outer_v

    covflat = covariance.ravel()
    corflat = correlation.ravel()
    cov0idx = np.abs(covflat) < 1e-6
    corflat[cov0idx] = 0

    return correlation

def convert_S_to_corr(Smat):
    
    n = Smat.shape[0]
    corrmat = np.zeros_like(Smat)
    
    for i in range(n):
        corrmat[i, :, :] = correlation_from_covariance(Smat[i, :, :])
        
    return corrmat


def gen_test_vectors():

    
        theta_a = np.array([[0.3, 0.6],
                            [0.5, 0.3]])

        theta_b = np.array([[0.1, 0.3, 0.5],
                            [0.34, 0.8, 0.6]])

        Amat = np.array(
                [
                    [[0.8, 0.4],
                    [0.4, 0.3]],

                    [[0.9, 0.4],
                    [0.4, 0.5]]
                ]
            )

        Bmat = np.array(
                [
                    [[0.5, 0.3, 0.3],
                    [0.3, 0.5, 0.5],
                    [0.3, 0.5, 0.9]],

                    [[0.7, 0.3, 0.3],
                    [0.3, 0.55, 0.5],
                    [0.3, 0.5, 0.85]]
                ]
            )

        A1 = np.array([[1.0, 0.0, 0.0],
                        [1.0, 0.5, 0.5]])
        A2 = np.eye(3)

        return theta_a, theta_b, Amat, Bmat, A1, A2


def gen_test_data(theta_a, theta_b, Amat, Bmat):

    '''
    theta_a, theta_b = theta vectors of two diff datasets
    Amat, Bmat = S matrices of two different dataset
    '''


    z_a = theta2z(theta_a, Amat)
    corra = convert_S_to_corr(Amat)

    adat = pd.DataFrame(
        {
            'cptid' : ['1:1', '1:3'],
            'CHR' : [1, 1],
            'SNP' : [10, 20],
            'BP' : [1, 3],
            'f' : [0.4, 0.6],
            'A1' : ['A', 'T'],
            'A2' : ['G', "C"],
            'phvar' : [1.0, 1.0],
            'estimated_effects' : ['direct_averageperental', 'direct_averageperental'],
            'theta_direct' : theta_a[:, 0],
            'se_direct' : np.sqrt(Amat[:, 0, 0]),
            'z_direct' : z_a[:, 0],
            'theta_population' : theta_a[:, 1],
            'se_population' : np.sqrt(Amat[:, 1, 1]),
            'z_population' : z_a[:, 1],
            'rg_direct_population': corra[:, 0, 1],
            'n_direct' : [100, 100],
            'n_population' : [200, 200]
        }
    )

    z_b = theta2z(theta_b, Bmat)
    corrb = convert_S_to_corr(Bmat)

    bdat = pd.DataFrame(
        {
            'cptid' : ['1:1', '1:2'],
            'CHR' : [1, 1],
            'SNP' : [10, 20],
            'BP' : [1, 2],
            'f' : [0.4, 0.6],
            'A1' : ['A', 'T'],
            'A2' : ['G', "C"],
            'phvar' : [1.0, 1.0],
            'estimated_effects' : ['direct_averageperental', 'direct_averageperental'],
            'theta_direct' : theta_b[:, 0],
            'se_direct' : np.sqrt(Bmat[:, 0, 0]),
            'z_direct' : z_b[:, 0],
            'theta_paternal' : theta_b[:, 1],
            'se_paternal' : np.sqrt(Bmat[:, 1, 1]),
            'z_paternal' : z_b[:, 1],
            'rg_direct_paternal': corrb[:, 0, 1],
            'rg_paternal_maternal': corrb[:, 1, 2],
            'theta_maternal' : theta_b[:, 2],
            'se_maternal' : np.sqrt(Bmat[:, 2, 2]),
            'z_maternal' : z_b[:, 2],
            'rg_direct_maternal': corrb[:, 0, 2],
            'n_direct' : [100, 100],
            'n_maternal' : [200, 200],
            'n_paternal' : [200, 200]
        }
    )


    missidxa = 1
    missidxb = 2

    return adat, bdat, missidxa, missidxb





class test_functions(unittest.TestCase):

    def test_fastmode(self):
        '''
        Testing if allele mode function is working fine
        '''

        dat_test = pd.DataFrame(
            {
                "A1" : ["AT", "CG", "AA", "AB", np.nan, np.nan],
                "A2" : ["AT", "AA", "AA", "AB", "BC", np.nan],
                "A3" : ["AT", "AA", "XX", "AB", "CD", np.nan],
                "A4" : ["AT", "AA", "XX", "YY", "CD", np.nan]
            }
        )

        fastmode = df_fastmode(dat_test, ["A1", "A2", "A3", "A4"])
        normalmode = dat_test[["A1", "A2", "A3", "A4"]].mode(axis="columns")[0]
        self.assertTrue(fastmode.equals(normalmode))

    def test_allele_align(self):
        '''
        Tests if allele alignment works
        '''

        dat_test = pd.DataFrame(
            {
                'SNP' : [1, 2, 3, 4, 5, 6],
                'allele_merge' : ['AGGA', 'ACAC', 'GTGT', 'TGGT', 'AGAG', 'ACCA'],
                'shouldflip' : [True, False, False, True, False, True],
                'z' : [0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
                'f' : [0.5, 0.6, 0.7, 0.8, 0.9, 1.0]
            }
        )

        # perform flipping manually
        dat_test.loc[dat_test['shouldflip'] == True, 'z_flip'] = -dat_test['z']
        dat_test.loc[dat_test['shouldflip'] == False, 'z_flip'] = dat_test['z']
        dat_test.loc[dat_test['shouldflip'] == True, 'f_flip'] = 1-dat_test['f']
        dat_test.loc[dat_test['shouldflip'] == False, 'f_flip'] = dat_test['f']
        
        dat_test = align_alleles(dat_test, 'z', 'f', 'allele_merge', chunksize = 2)

        z_align = np.alltrue(np.isclose(dat_test['z'], dat_test['z_flip']))
        f_align = np.alltrue(np.isclose(dat_test['f'], dat_test['f_flip']))

        all_align = z_align and f_align

        self.assertTrue(all_align)

    def test_extract_first(self):
        '''
        tests whether extractor works
        '''

        dict_of_vecs = dict(
            A = np.array([1.0, 1.0, 1.0, 1.0]),
            B = np.array([np.nan, 100.0, 100.0]),
            C = np.array([
                [[1.0, 2.0], [2.0, 4.0]],
                [[1.0, 2.0], [2.0, 4.0]],
                [[1.0, 2.0], [2.0, 4.0]]
            ]),
            D = np.array([
                [[np.nan, 2.0], [2.0, 4.0]],
                [[1.0, 2.0], [2.0, 4.0]],
                [[1.0, 2.0], [2.0, 4.0]]
            ]),
            E = np.array([
                [[np.nan, np.nan], [np.nan, np.nan]],
                [[1.0, 2.0], [2.0, 4.0]],
                [[1.0, 2.0], [2.0, 4.0]]
            ])
        )

        scalars = get_firstvalue_dict(dict_of_vecs)
        true1 = np.isclose(scalars['A'], 1.0)
        true2 = np.isclose(scalars['B'], 100.0)
        true3 = np.allclose(scalars['C'], np.array([[1.0, 2.0], [2.0, 4.0]]))
        true4 = np.allclose(scalars['D'], np.array([[1.0, 2.0], [2.0, 4.0]]))
        true5 = np.allclose(scalars['E'], np.array([[1.0, 2.0], [2.0, 4.0]]))

        self.assertTrue(true1 and true2 and true3 and true4 and true5)

    def test_wt_calc(self):
        '''
        tests how we get weights
        '''
        theta_a, theta_b, Amat, Bmat, A1, A2 = gen_test_vectors()

        S_dict = dict(
            A = Amat,
            B = Bmat
        )

        
        wt_a = A1.T @ np.linalg.inv(Amat)
        wt_b = A2.T @ np.linalg.inv(Bmat)

        atransform_dict = dict(
            A = A1,
            B = A2
        )
    
        wt_dict = get_wts(atransform_dict, S_dict)

        Aallclose = np.allclose(wt_a, wt_dict['A'])
        Ballclose = np.allclose(wt_b, wt_dict['B'])

        bothclose = Aallclose and Ballclose

        self.assertTrue(bothclose)


    def test_theta_wted_sum(self):

        theta_a, theta_b, Amat, Bmat, A1, A2 = gen_test_vectors()

        theta_dict = dict(
            A = theta_a,
            B = theta_b
        )

        wt_dict = dict(
            A = A1.T @ np.linalg.inv(Amat),
            B = A2.T @ np.linalg.inv(Bmat)
        )

        theta_weighted_sum = theta_wted_sum(theta_dict, wt_dict)

        theta_wted_sum_manual = A1.T @ np.linalg.inv(Amat) @ theta_a[..., None]  + A2.T @ np.linalg.inv(Bmat) @ theta_b[..., None]

        self.assertTrue(np.allclose(theta_weighted_sum, theta_wted_sum_manual))

    def test_theta_var(self):

        theta_a, theta_b, Amat, Bmat, A1, A2 = gen_test_vectors()
        
        wt_a = A1.T @ np.linalg.inv(Amat)
        wt_b = A2.T @ np.linalg.inv(Bmat)

        wt_dict = dict(
            A = A1.T @ np.linalg.inv(Amat),
            B = A2.T @ np.linalg.inv(Bmat)
        )

        wtsum = wt_a @ A1 + wt_b @ A2
        theta_var_manual = np.linalg.inv(wtsum)

        atransform_dict = dict(
            A = A1,
            B = A2
        )
        theta_var = get_theta_var(wt_dict, atransform_dict)

        self.assertTrue(np.allclose(theta_var, theta_var_manual))

    def test_core_meta(self):

        '''
        Tests the core meta analysis pipeline (just the numpy stuff)
        '''

        theta_a, theta_b, Amat, Bmat, A1, A2 = gen_test_vectors()

        theta_dict = dict(
            A = theta_a,
            B = theta_b
        )

        wt_a = A1.T @ np.linalg.inv(Amat)
        wt_b = A2.T @ np.linalg.inv(Bmat)

        theta_wted_sum_manual = wt_a @ theta_a[..., None]  + wt_b @ theta_b[..., None]
        theta_out_manual = theta_wted_sum_manual
        wtsum = wt_a @ A1 + wt_b @ A2
        theta_var_manual = np.linalg.inv(wtsum)
        theta_estimates_manual = theta_var_manual @ theta_out_manual


        A1_test = getamat("direct_population", "direct_maternal_paternal")
        A2_test = getamat("direct_maternal_paternal", "direct_maternal_paternal")
        wt_dict = dict(
            A = A1_test.T @ np.linalg.inv(Amat),
            B = A2_test.T @ np.linalg.inv(Bmat)
        )

        atransform_dict = dict(
            A = A1_test,
            B = A2_test
        )

        theta_estimates, _ = get_estimates(theta_dict, wt_dict, atransform_dict)
        self.assertTrue(np.allclose(theta_estimates, theta_estimates_manual))

    def test_endtoend(self):

        '''
        Tests the package end to end
        '''

        theta_a, theta_b, Amat, Bmat, A1, A2 = gen_test_vectors()
        adat, bdat, missidxa, missidxb = gen_test_data(theta_a, theta_b, Amat, Bmat)
        adat.to_csv("tmp_adat.gz", sep=" ", index=False)
        bdat.to_csv("tmp_bdat.gz", sep=" ", index=False)

        # =========== manual answers ============== #

        # insert missing values into numpy vectors
        theta_a = np.insert(theta_a, [missidxa], [0, 0],axis=0)
        theta_b = np.insert(theta_b, [missidxb], [0, 0, 0],axis=0)

        Amatinv = np.linalg.inv(Amat)
        Bmatinv = np.linalg.inv(Bmat)

        Amatinv = np.insert(Amatinv, [missidxa], [[0, 0], [0, 0]],axis=0)
        Bmatinv = np.insert(Bmatinv, [missidxb], [[0, 0, 0], [0, 0, 0], [0, 0, 0]],axis=0)


        theta_estimates_manual = np.empty(shape = (0, 5))
        theta_var_manual = np.empty(shape = (0, 5, 5))

        for snps in [(0, 1), (2)]:

            # we need to meta analyze the snp where we have
            # only direct_population effect seperately
            # b is the cohort where we have all effects
            effect = 'full' if snps == (0,1) else 'direct_population'

            A1_mat = A1 if snps == (0, 1) else np.eye(2)
            A2_mat = A2 if snps == (0, 1) else np.zeros((3,2))

            wt_a = A1_mat.T @ Amatinv[snps, ...]
            wt_b = A2_mat.T @ Bmatinv[snps, ...]

            theta_wted_sum_manual = wt_a @ theta_a[snps, ..., None]  + wt_b @ theta_b[snps, ..., None]
            theta_out_manual = theta_wted_sum_manual
            wtsum = wt_a @ A1_mat + wt_b @ A2_mat
            theta_var_manual_tmp = np.linalg.inv(wtsum)
            theta_est_manual_tmp = theta_var_manual_tmp @ theta_out_manual

            if snps != (0,1):
                theta_var_manual_tmp = theta_var_manual_tmp[None, ...]

            theta_var_manual_tmp, theta_est_manual_tmp = transform_estimates(
                effect,
                "full_averageparental_population",
                theta_var_manual_tmp, 
                theta_est_manual_tmp[..., 0]
            )
            theta_var_manual = np.vstack((theta_var_manual, theta_var_manual_tmp))
            theta_estimates_manual= np.vstack((theta_estimates_manual, theta_est_manual_tmp)) 

        # =========== package answers ============== #

        inputopts = {
            "a" : {

                "path2file" : "tmp_adat.gz"

            },

            "b": {
                "path2file" : "tmp_bdat.gz"
            }
        }

        json_data = json.dumps(inputopts, indent = 4)
        with open("tmp_inputopts.json", "w") as outfile:
            outfile.write(json_data)

        # run meta analysis
        command = ["python",
                   "/var/genetics/proj/within_family/within_family_project/scripts/package/run_metaanalysis.py",
                   'tmp_inputopts.json',
                   '--outestimates', "direct_population",
                   '--outprefix', 'tmp_out',
                   '--nohm3', '--nomediannfilter'
                   ]
        subprocess.check_call(command)

        # read in outputted data
        datout = pd.read_csv('tmp_out.sumstats.gz', delim_whitespace=True)
        
        # reading hdf5
        with h5py.File('tmp_out.sumstats.hdf5', 'r') as hf:
            theta_hf = hf['estimate'][()]
            s_sf = hf['estimate_covariance'][()]

        
        # clean up files
        os.remove('tmp_out.sumstats.gz')
        os.remove('tmp_out.sumstats.hdf5')
        os.remove('tmp_inputopts.json')
        os.remove('tmp_adat.gz')
        os.remove('tmp_bdat.gz')
        
        thetaout = datout[['direct_Beta', 'paternal_Beta', 'maternal_Beta', 'avg_NTC_Beta', 'population_Beta']].values
        
        
        sdir = datout['direct_SE'].values**2
        spat = datout['paternal_SE'].values**2
        smat = datout['maternal_SE'].values**2
        sap = datout['avg_NTC_SE'].values**2
        spop = datout['population_SE'].values**2

        rg_dirpat  = datout['r_direct_paternal'].values
        rg_dirmat  = datout['r_direct_maternal'].values
        rg_patmat  = datout['r_paternal_maternal'].values
        rg_dirap = datout['r_direct_avg_NTC'].values
        rg_dirpop = datout['r_direct_population'].values
        rg_patap = datout['r_paternal_avg_NTC'].values
        rg_matap = datout['r_maternal_avg_NTC'].values
        rg_patpop = datout['r_paternal_population'].values
        rg_matpop = datout['r_maternal_population'].values
        rg_avgpar_pop = datout['r_avg_parental_population'].values

        cov_dirpat = rg_dirpat * np.sqrt(sdir) * np.sqrt(spat)
        cov_dirmat = rg_dirmat * np.sqrt(sdir) * np.sqrt(smat)
        cov_patmat = rg_patmat * np.sqrt(spat) * np.sqrt(smat)
        cov_dirap = rg_dirap * np.sqrt(sdir) * np.sqrt(sap)
        cov_dirpop = rg_dirpop * np.sqrt(sdir) * np.sqrt(spop)
        cov_patap = rg_patap * np.sqrt(spat) * np.sqrt(sap)
        cov_matap = rg_matap * np.sqrt(smat) * np.sqrt(sap)
        cov_patpop = rg_patpop * np.sqrt(spat) * np.sqrt(spop)
        cov_matpop = rg_matpop * np.sqrt(smat) * np.sqrt(spop)
        cov_appop = rg_avgpar_pop * np.sqrt(sap) * np.sqrt(spop)

        sout = np.zeros((3, 5, 5))
        sout[:, 0, 0] = sdir
        sout[:, 1, 1] = spat
        sout[:, 2, 2] = smat
        sout[:, 3, 3] = sap
        sout[:, 4, 4] = spop
        sout[:, 0, 1] = cov_dirpat
        sout[:, 1, 0] = cov_dirpat
        sout[:, 0, 2] = cov_dirmat
        sout[:, 2, 0] = cov_dirmat
        sout[:, 1, 2] = cov_patmat
        sout[:, 2, 1] = cov_patmat
        sout[:, 0, 3] = cov_dirap
        sout[:, 3, 0] = cov_dirap
        sout[:, 0, 4] = cov_dirpop
        sout[:, 4, 0] = cov_dirpop
        sout[:, 1, 3] = cov_patap
        sout[:, 3, 1] = cov_patap
        sout[:, 2, 3] = cov_matap
        sout[:, 3, 2] = cov_matap
        sout[:, 1, 4] = cov_patpop
        sout[:, 4, 1] = cov_patpop
        sout[:, 2, 4] = cov_matpop
        sout[:, 4, 2] = cov_matpop
        sout[:, 3, 4] = cov_appop
        sout[:, 4, 3] = cov_appop

        thetasame_txt = np.allclose(thetaout, theta_estimates_manual, equal_nan=True)
        ssame_txt = np.allclose(sout, theta_var_manual, equal_nan=True)
        thetasame_hf = np.allclose(theta_hf, theta_estimates_manual, equal_nan=True)
        ssame_hf = np.allclose(s_sf, theta_var_manual, equal_nan=True)

        self.assertTrue(thetasame_txt and ssame_txt and thetasame_hf and ssame_hf)



if __name__ == '__main__':
    np.random.seed(123)
    unittest.main()