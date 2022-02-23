import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import h5py
from numba import njit


plt.rcParams['text.usetex'] = True


def transform_estimates(fromest,
                        toest,
                        S, theta):

    '''
    Transforms theta (can also be z) and S data into
    the required format from a given format
    like direct + average parental to direct + population

    possible effects:
    - full - refers to (direct, maternal effect, paternal effect) 
    - direct_averageparental - refers to (direct, average_parental)
    - direct_population - refers to (direct, population)
    - population - refers to (population)
    '''

    # preprocess some input possibilities
    if fromest == "direct_maternal_paternal" or fromest == "direct_paternal_maternal":
        fromest = "full"
    if toest == "direct_maternal_paternal" or toest == "direct_paternal_maternal":
        toest = "full"
    if fromest == "direct_avgparental":
        fromest = "direct_averageparental"

    if fromest == toest:
        pass
    elif fromest == "full" and toest == "direct_population":
        print("Converting from full to direct + Population")

        # == keeping direct effect and population effect == #
        tmatrix = np.array([[1.0, 1.0],
                            [0.0, 0.5],
                            [0.0, 0.5]])
        Sdir = np.empty((len(S), 2, 2))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix

        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    
    elif fromest == "full" and toest == "direct_averageparental":

        print("Converting from full to direct + average parental")

        # == Combining indirect effects to make V a 2x2 matrix == #
        tmatrix = np.array([[1.0, 0.0],
                            [0.0, 0.5],
                            [0.0, 0.5]])
        Sdir = np.empty((len(S), 2, 2))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix
        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    
    elif fromest == "direct_averageparental" and toest == "direct_population":

        print("Converting from direct + average parental to direct + population")

        tmatrix = np.array([[1.0, 1.0],
                            [0.0, 1.0]])
        
        Sdir = tmatrix.T @ S @ tmatrix

        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    
    elif fromest == "direct_population" and toest == "direct_averageparental":
        print("Converting from population to average parental")

        tmatrix = np.array([[1.0, -1.0],
                            [0.0, 1.0]])
        Sdir = np.empty((len(S), 2, 2))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix

        S = Sdir.reshape((len(S), 2, 2))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 2))
    elif (fromest == "full" and toest == "full_averageparental_population") | (fromest == "full" and toest == "direct_paternal_maternal_averageparental_population"):
        print("Converting from full to full + average parental  + population")

        tmatrix = np.array([[1.0, 0.0, 0.0, 0.0, 1.0],
                            [0.0, 1.0, 0.0, 0.5, 0.5],
                            [0.0, 0.0, 1.0, 0.5, 0.5]])
        Sdir = np.empty((len(S), 5, 5))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix
        S = Sdir.reshape((len(S), 5, 5))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 5))
    elif (fromest == "direct_population" and toest == "full_averageparental_population") | (fromest == "direct_population" and toest == "direct_paternal_maternal_averageparental_population"):

        print("Converting from direct population to full + average parental + population")

        tmatrix = np.array([[1.0, np.nan, np.nan, -1.0, 0.0],
                            [0.0, np.nan, np.nan, 1.0, 1.0]])
        Sdir = np.empty((len(S), 5, 5))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix

        S = Sdir.reshape((len(S), 5, 5))
        theta = np.atleast_2d(theta @ tmatrix)
        theta = theta.reshape((theta.shape[0], 5))

    elif (fromest == "direct_averageparental" and toest == "full_averageparental_population") | (fromest == "direct_averageparental" and toest == "direct_paternal_maternal_averageparental_population"):

        print('Converting from direct population to full + average parental + population')

        tmatrix = np.array([[1.0, np.nan, np.nan, 0.0, 1.0],
                            [0.0, np.nan, np.nan, 1.0, 1.0]])
        Sdir = np.empty((len(S), 5, 5))
        for i in range(len(S)):
            Sdir[i] = tmatrix.T @ S[i] @ tmatrix
        S = Sdir.reshape((len(S), 5, 5))
        theta = theta @ tmatrix
        theta = theta.reshape((theta.shape[0], 5))
    else:
        print("Warning: The given parameters hasn't been converted.")


    return S, theta

@njit(cache = True)
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

theta_vec = np.empty(shape = (0, 5))
S_vec = np.empty(shape = (0, 5, 5))
for chr in range(1, 23):
    fname = f'/var/genetics/data/ukb/public/latest/raw/sumstats/fgwas/21/chr_{chr}.sumstats.hdf5'
    with h5py.File(fname, 'r') as hf:
        
        print(f'Reading in file {fname}')
        estimates = hf['estimate'][()]
        vcov = hf['estimate_covariance'][()]

        vcov, estimates = transform_estimates('full', 'full_averageparental_population', vcov, estimates)
        
        theta_vec = np.vstack((theta_vec, estimates))
        S_vec = np.vstack((S_vec, vcov))

covmat = convert_S_to_corr(S_vec)
dat = pd.DataFrame({
    'rg_dir_avgparental' : covmat[:, 0, 3],
    'rg_dir_pop' : covmat[:, 0, 4]
})
print(dat.head())
kdeplot = sns.kdeplot(data=dat, x = 'rg_dir_pop', y = 'rg_dir_avgparental', fill=True, thresh=0.001)
kdeplot.set_xlabel("Direct to Population Sampling Correlation")
kdeplot.set_ylabel("Direct to Average NTC Sampling Correlation")
fig = kdeplot.get_figure()
fig.savefig("/var/genetics/proj/within_family/within_family_project/doc/exampleplots/ukb_rg_plot.png")
