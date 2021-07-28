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
        print(fastmode)
        print(normalmode)

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
        



if __name__ == '__main__':
    np.random.seed(123)
    unittest.main()