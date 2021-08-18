import numpy as np
import scipy.stats
from parsedata import *

def min_dim(xdict, axis = 1):
    '''
    Figure out what the highest dimension value is
    along a particular axis

    xdict: a dictionary of arrays
    '''

    cohorts = list(xdict.keys())
    
    dimsizes = []
    for c in cohorts:
        dimsize = xdict[c].shape[axis]
        dimsizes += [dimsize]
    
    minsofar = min(dimsizes)
    
    # find all cohorts with the maxdimsize
    mincohorts = []
    for c in cohorts:
        dimsize = xdict[c].shape[axis]
        if dimsize == minsofar:
            mincohorts += [c]

    return minsofar, mincohorts

def dict_dim(xdict, axis = 1):
    '''
    Get dimension/axis size of a set of arrays
    stored in a dictionray. The function
    checks also if the dimensions are the same
    for all elements in the dictionary
    '''

    cohorts = list(xdict.keys())
    x1 = xdict[cohorts[0]]
    dimout = x1.shape[axis]

    cond = True
    for c in cohorts:
        dimsame = dimout == xdict[c].shape[axis]
        cond = cond and dimsame
    
    if not cond:
        print("Warning: Dimenions dont seem to match across dictionary!")

    return dimout



def adjust_S_by_phvar(S_dict, phvar_dict):
    '''
    Dividng a dictionary of S estimates by
    phenotypic varaince dictionary
    '''

    
    S_out = {}
    assert S_dict.keys() == phvar_dict.keys()
    
    for cohort in S_dict:
        S_out[cohort] = (1/phvar_dict[cohort]) * S_dict[cohort]
        
    return S_out
    
    
def adjust_theta_by_phvar(theta_dict, phvar_dict):
    '''
    Diving FGWAS effect estimaates by
    square root of phenotypic varianace
    '''

    
    theta_out = {}
    assert theta_dict.keys() == phvar_dict.keys()
    
    for cohort in theta_dict:
        theta_out[cohort] = (1/np.sqrt(phvar_dict[cohort])) * theta_dict[cohort]
        
    return theta_out



def get_wts(A, S_dict):
    '''
    Dictionary of S matrices and A matrices
    to be made into weights
    '''
    
    wt_dict = {}
    for cohort in S_dict:
        S_mat = np.atleast_2d(S_dict[cohort])
        wt_dict[cohort] = A[cohort].T @ np.linalg.inv(S_mat)
        
    return wt_dict



def get_wt_sum(wt):
    
    '''
    Get sum of weights.
    Used for calculating variance covariance matrix
    of estimates
    
    Also used as the effective N potentially for
    direct and indirect effects
    '''

    
    cohorts = list(wt.keys())
    wtsum = np.zeros_like(wt[cohorts[0]])
    
    for cohort in cohorts:
        wtsum += wt[cohort]
        
    return wtsum



def get_theta_var(wt, A):
    '''
    Get variance cov matrix of 
    meta analyzed estimate
    '''

    cohorts = list(wt.keys())
    ndim1 = dict_dim(wt, axis = 1)
    ndim2, _ = min_dim(wt, axis = 2)
    wtsum = np.zeros((wt[cohorts[0]].shape[0], ndim1, ndim2))

    for cohort in cohorts:
        wtsum += wt[cohort] @ A[cohort]

    theta_var = np.linalg.inv(wtsum)
    
    return theta_var



def theta_wted_sum(theta_dict, wt_dict):
    
    '''
    Get weighted sum of theta
    
    Notes: [..., None] at the end of an numpy array
    adds an extra dimenion to it. It is used
    here to make arrays conform
    
    '''


    assert theta_dict.keys() == wt_dict.keys()
    cohorts = list(theta_dict.keys())
    ndimout = dict_dim(wt_dict)
    theta_bar = np.zeros((theta_dict[cohorts[0]].shape[0], ndimout, 1))

    for cohort in theta_dict:
        theta_bar += wt_dict[cohort] @ theta_dict[cohort][..., None]
    
    return theta_bar



def get_estimates(theta_dict, wt_dict, A):
    
    '''
    Get meta analyzed theta.
    '''
    
    theta_bar = theta_wted_sum(theta_dict, wt_dict)
    # wt_sum = get_wt_sum(wt_dict)
    theta_var = get_theta_var(wt_dict, A)
    theta_bar = theta_var @ theta_bar
        
    return theta_bar, theta_var#, wt_sum


def get_ses(var):
    
    ses = np.zeros((len(var), 2))
    for i in range(len(var)):
        ses[i] = np.sqrt(np.diag(var[i]))
        
    return ses


def get_pval(z):
    
    '''
    Get pvalue from z values
    '''
    
    return 2*scipy.stats.norm.sf(np.abs(z))



def extract_portion(wt_dict, effect = 0):
    
    '''
    Extract either first component or second component
    of wt_dict
    '''
    
    wt_out = {}
    
    for cohort in wt_dict:
        wt_out[cohort] = wt_dict[cohort][:, effect, effect]
    
    return wt_out
    
    
def freq_wted_sum(f_dict, wt_dict):
    
    assert f_dict.keys() == wt_dict.keys()
    cohorts = list(f_dict.keys())
    f_bar = np.zeros_like(f_dict[cohorts[0]])
    
    for cohort in cohorts:
        f_bar += wt_dict[cohort] * f_dict[cohort]
    
    return f_bar


def neff(f, se, phvar = 1):
    '''
    Get Effective N
    '''

    N = np.round(phvar*(2*f*(1-f)*se**2)**(-1))
    return N
