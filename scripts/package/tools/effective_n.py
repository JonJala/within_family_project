import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import argparse

def neff(f, se, phvar = 1):
    '''
    Get Effective N
    '''

    N = np.round(phvar*(2*f*(1-f)*se**2)**(-1))
    return N


if __name__ == '__main__':

    parser=argparse.ArgumentParser()
    parser.add_argument('datapath', type=str, 
                        help='''Path to json file describing input
                        files''')
    parser.add_argument('--f', type=str, default = "freq",
                        help='''name of allele frequency column''')
    parser.add_argument('--snp', type=str, default = "SNP",
                        help='''name of rsid column''')
    parser.add_argument('--se', type=str, default = "se",
                        help='''name of SE column''')
    parser.add_argument('--phvar', type = float, default = 1.0,
                        help='''phenotypic variance value''')
    parser.add_argument('--hm3', type = str, default = "/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist",
                        help='''Path to hm3 snp list''')
    parser.add_argument('--plotoutpath', type=str, 
                        help='''path to output plot of effective n distribution''')

    args=parser.parse_args()

    dat = pd.read_csv(args.datapath, delim_whitespace=True)
    info = pd.read_csv(args.hm3, delim_whitespace=True)
    dat_hm3 = dat[dat[args.snp].isin(info.SNP)]

    Neff = neff(dat[args.f], dat[args.se], args.phvar)
    Neff_hm3 = neff(dat_hm3[args.f], dat_hm3[args.se], args.phvar)

    median_neff = np.median(Neff)
    median_neff_hm3 = np.median(Neff_hm3)
    print(f"Median Effective N is {median_neff}")
    print(f"Median Effective N in HM3 SNPs is is {median_neff_hm3}")

    if args.plotoutpath is not None:

        fig, ax = plt.subplots(figsize = (10, 6))
        sns.distplot(Neff, ax = ax)
        sns.distplot(Neff_hm3, ax = ax)
        ax.set_title("Distribution of Effective N")
        plt.savefig(args.plotoutpath, dpi = 300)

