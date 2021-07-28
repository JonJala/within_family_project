import unittest
import numpy as np
import pandas as pd
from run_metaanalysis import *



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

    def test_wt_calc(self):
        '''
        tests how we get weights
        '''
        Amat = np.array(
                [
                    [[0.5, 0.3],
                    [ 0.3, 0.5]],

                    [[0.3, 0.6],
                    [0.6, 0.1]]
                ]
            )

        Bmat = np.array(
                [
                    [[0.1, 0.5],
                    [0.5, 0.5]],

                    [[0.3, 0.3],
                    [0.3, 0.55]]
                ]
            )
        S_dict = dict(
            A = Amat,
            B = Bmat
        )
        wt_a = np.linalg.inv(Amat)
        wt_b = np.linalg.inv(Bmat)
        
        wt_dict = get_wts(S_dict)

        Aallclose = np.allclose(wt_a, wt_dict['A'])
        Ballclose = np.allclose(wt_b, wt_dict['B'])

        bothclose = Aallclose and Ballclose

        self.assertTrue(bothclose)

    def test_wtsum(self):

        Amat = np.array(
                [
                    [[0.5, 0.3],
                    [ 0.3, 0.5]],

                    [[0.3, 0.6],
                    [0.6, 0.1]]
                ]
            )

        Bmat = np.array(
                [
                    [[0.1, 0.5],
                    [0.5, 0.5]],

                    [[0.3, 0.3],
                    [0.3, 0.55]]
                ]
            )
        S_dict = dict(
            A = Amat,
            B = Bmat
        )

        wt_a = np.linalg.inv(Amat)
        wt_b = np.linalg.inv(Bmat)

        wt_sum_manual = wt_a + wt_b

        wt_dict = dict(
            A = wt_a,
            B = wt_b
        )

        wt_sum = get_wt_sum(wt_dict)

        self.assertTrue(np.allclose(wt_sum, wt_sum_manual))

    def test_theta_wted_sum(self):
        theta_a = np.array([[0.3, 0.6],
                            [0.5, 0.3]])

        theta_b = np.array([[0.1, 0.3],
                            [0.34, 0.8]])

        theta_dict = dict(
            A = theta_a,
            B = theta_b
        )

        Amat = np.array(
                [
                    [[0.5, 0.3],
                    [ 0.3, 0.5]],

                    [[0.3, 0.6],
                    [0.6, 0.1]]
                ]
            )

        Bmat = np.array(
                [
                    [[0.1, 0.5],
                    [0.5, 0.5]],

                    [[0.3, 0.3],
                    [0.3, 0.55]]
                ]
            )
        wt_dict = dict(
            A = np.linalg.inv(Amat),
            B = np.linalg.inv(Bmat)
        )

        theta_weighted_sum = theta_wted_sum(theta_dict, wt_dict)

        print(theta_a[..., None])

        theta_wted_sum_manual = np.linalg.inv(Amat) @ theta_a[..., None]  + np.linalg.inv(Bmat) @ theta_b[..., None]

        self.assertTrue(np.allclose(theta_weighted_sum, theta_wted_sum_manual))


if __name__ == '__main__':
    np.random.seed(123)
    unittest.main()