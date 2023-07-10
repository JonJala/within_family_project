import pandas as pd
import numpy as np
import argparse

## format qc'd sumstats for correlate.py

parser=argparse.ArgumentParser()
parser.add_argument('--sumstats', type=str, 
                    help='File path to QCd sumstats')
parser.add_argument('--outpath', type=str, 
                    help='Output file path')
args=parser.parse_args()

ss = pd.read_csv(args.sumstats, sep=" ")
final = pd.DataFrame(columns = ["chromosome", "SNP", "pos", "A1", "A2", "freq", "direct_N", "direct_Beta", "direct_SE", "direct_Z", "direct_log10_P", "paternal_N",
                                "paternal_Beta", "paternal_SE", "paternal_Z", "paternal_log10_P", "maternal_N", "maternal_Beta", "maternal_SE", "maternal_Z",
                                "maternal_log10_P", "avg_NTC_N", "avg_NTC_Beta", "avg_NTC_SE", "avg_NTC_Z", "avg_NTC_log10_P", "population_N", "population_Beta",
                                "population_SE", "population_Z", "population_log10_P", "r_direct_avg_NTC", "r_direct_population", "r_paternal_maternal"])

final["chromosome"] = ss["CHR"].astype('Int64')
final["SNP"] = ss["SNP"].astype(object)
final["pos"] = ss["BP"].astype('Int64')
final["A1"] = ss["A1"].astype(object)
final["A2"] = ss["A2"].astype(object)
final["freq"] = ss["f"].astype('float64')
final["direct_N"] = ss["n_direct"].astype('Int64')
final["direct_Beta"] = ss["theta_direct"].astype('float64')
final["direct_SE"] = ss["se_direct"].astype('float64')
final["direct_Z"] = ss["z_direct"].astype('float64')
final["direct_log10_P"] = ss["PVAL_direct"].astype('float64')
final["population_N"] = ss["n_population"].astype('Int64')
final["population_Beta"] = ss["theta_population"].astype('float64')
final["population_SE"] = ss["se_population"].astype('float64')
final["population_Z"] = ss["z_population"].astype('float64')
final["population_log10_P"] = ss["PVAL_population"].astype('float64')
final["r_direct_population"] = ss["rg_direct_population"].astype('float64')

np.savetxt(args.outpath, final.values, fmt='%s', delimiter=' ', header = ' '.join(final.columns), comments = "")
