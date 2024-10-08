import h5py
import numpy as np
from math import log10
from scipy.stats import chi2
import argparse
import glob
import os

## note: i think this script can be deleted. i think it has been incorporated into correlation_meta_functions

parser = argparse.ArgumentParser()
parser.add_argument('--sumstats', type=str, 
                    help='Path to sumstats file(s). Use * to specify multiple files.')
parser.add_argument('--chrposid', action='store_true', default = False, help = 'Whether to make SNP ID chr:pos ID')
parser.add_argument('--parsum', action='store_true', default = False, help = "Whether to sum paternal and maternal effects")
args = parser.parse_args()

## functions from SNIPar gwas.py

def outarray_effect(est, ses, freqs, vy):
    N_effective = vy/(2*freqs*(1-freqs)*np.power(ses,2))
    Z = est/ses
    P = -log10(np.exp(1))*chi2.logsf(np.power(Z,2),1)
    array_out = np.column_stack((N_effective,est,ses,Z,P))
    array_out = np.round(array_out, decimals=6)
    array_out[:,0] = np.round(array_out[:,0], 0)
    return array_out

def write_txt_output(chrom, snp_ids, pos, alleles, outfile, parsum, sib, alpha, alpha_cov, sigma2, tau, freqs):
    outbim = np.column_stack((chrom, snp_ids, pos, alleles,np.round(freqs,3)))
    header = ['chromosome','SNP','pos','A1','A2','freq']
    # Which effects to estimate
    effects = ['direct']
    if sib:
        effects.append('sib')
    if not parsum:
        effects += ['paternal','maternal']
    effects += ['avg_NTC','population']
    effects = np.array(effects)
    if not parsum:
        paternal_index = np.where(effects=='paternal')[0][0]
        maternal_index = np.where(effects=='maternal')[0][0]
    avg_NTC_index = np.where(effects=='avg_NTC')[0][0]
    population_index = avg_NTC_index+1
    # Get transform matrix
    A = np.zeros((len(effects),alpha.shape[1]))
    A[0:alpha.shape[1],0:alpha.shape[1]] = np.identity(alpha.shape[1])
    if not parsum:
        A[alpha.shape[1]:(alpha.shape[1]+2), :] = 0.5
        A[alpha.shape[1], 0] = 0
        A[alpha.shape[1]+1, 0] = 1
    else:
        A[alpha.shape[1], :] = 1
    # Transform effects
    alpha = alpha.dot(A.T)
    alpha_ses_out = np.zeros((alpha.shape[0],A.shape[0]))
    corrs = ['r_direct_avg_NTC','r_direct_population']
    if sib:
        corrs.append('r_direct_sib')
    if not parsum:
        corrs.append('r_paternal_maternal')
    ncor = len(corrs)
    alpha_corr_out = np.zeros((alpha.shape[0],ncor))
    for i in range(alpha_cov.shape[0]):
        alpha_cov_i = A.dot(alpha_cov[i,:,:].dot(A.T))
        alpha_ses_out[i,:] = np.sqrt(np.diag(alpha_cov_i))
        # Direct to average NTC
        alpha_corr_out[i,0] = alpha_cov_i[0,avg_NTC_index]/(alpha_ses_out[i,0]*alpha_ses_out[i,avg_NTC_index])
        # Direct to population
        alpha_corr_out[i,1] = alpha_cov_i[0,population_index]/(alpha_ses_out[i,0]*alpha_ses_out[i,population_index])
        # Direct to sib
        if sib:
            alpha_corr_out[i,2] = alpha_cov_i[0,1]/(alpha_ses_out[i,0]*alpha_ses_out[i,1])
        # Paternal to maternal
        if not parsum:
            alpha_corr_out[i,ncor-1] = alpha_cov_i[paternal_index,maternal_index]/(alpha_ses_out[i,maternal_index]*alpha_ses_out[i,paternal_index])
    # Create output array
    vy = (1+1/tau)*sigma2
    outstack = [outbim]
    for i in range(len(effects)):
        outstack.append(outarray_effect(alpha[:,i],alpha_ses_out[:,i],freqs,vy))
        header += [effects[i]+'_N',effects[i]+'_Beta',effects[i]+'_SE',effects[i]+'_Z',effects[i]+'_log10_P']
    outstack.append(np.round(alpha_corr_out,6))
    header += corrs
    # Output array
    outarray = np.row_stack((np.array(header),np.column_stack(outstack)))
    print('Writing text output to '+outfile)
    np.savetxt(outfile, outarray, fmt='%s')

## read in sumstats
files = glob.glob(args.sumstats)

for i in range(len(files)):

    file = files[i]
    print('Reading '+file)
    hf = h5py.File(file, 'r')

    metadata = np.array(hf['bim'])
    chr = metadata[:, 0].astype(float).astype(int)
    pos = metadata[:, 2].astype(float).astype(int)
    if args.chrposid:
        def get_chrposid(a, b):
            if a is None or b is None:
                return np.nan
            return str(a) + ":" + str(b)
        SNP = [get_chrposid(a, b) for a, b in zip(chr, pos)]
        SNP = np.array(SNP)
    else:
        SNP = metadata[:, 1]
    alleles = metadata[:, 3:5]
    theta  = hf.get('estimate')[()]
    S = hf.get('estimate_covariance')[()]
    f = hf.get('freqs')[()]
    sigma2 = hf.get('sigma2')[()]
    tau = hf.get('tau')[()]

    outfile = file.replace('/raw/', '/processed/') # processed directory
    outfile = outfile.replace(outfile.split("/").pop(), "gz/" + outfile.split("/").pop()) # gz subfolder
    if file.endswith('.sumstats.hdf5'):
        outfile = outfile.replace('.hdf5', '.gz')
    elif file.endswith('.hdf5'):
        outfile = outfile.replace('.hdf5', '.sumstats.gz')
    if '/hdf5/' in file:
        outfile = outfile.replace('/hdf5/', '')

    os.makedirs(outfile.replace(outfile.split("/").pop(), ""), exist_ok=True)

    write_txt_output(chrom = chr, snp_ids = SNP, pos = pos, alleles = alleles, outfile = outfile, alpha = theta, alpha_cov= S, sigma2=sigma2, tau=tau, freqs=f, parsum = args.parsum, sib = False)
