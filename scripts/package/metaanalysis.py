import numpy as np
import scipy.stats
from parsedata import *


def adjust_S_by_phvar(S_dict, phvar_dict):
    
    S_out = {}
    assert S_dict.keys() == phvar_dict.keys()
    
    for cohort in S_dict:
        S_out[cohort] = (1/phvar_dict[cohort]) * S_dict[cohort]
        
    return S_out
    
    
def adjust_theta_by_phvar(theta_dict, phvar_dict):
    
    theta_out = {}
    assert theta_dict.keys() == phvar_dict.keys()
    
    for cohort in theta_dict:
        theta_out[cohort] = (1/np.sqrt(phvar_dict[cohort])) * theta_dict[cohort]
        
    return theta_out



def get_wts(S_dict):
    
    wt_dict = {}
    
    for cohort in S_dict:
        wt_dict[cohort] = np.linalg.inv(S_dict[cohort])
        
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



def get_theta_var(wtsum):
    '''
    Get variance cov matrix of 
    meta analyzed estimate
    '''
        
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
    theta_bar = np.zeros_like(theta_dict[cohorts[0]])[..., None]
    
    for cohort in theta_dict:
        theta_bar += wt_dict[cohort] @ theta_dict[cohort][..., None]
    
    return theta_bar



def get_estimates(theta_dict, wt_dict):
    
    '''
    Get meta analyzed theta.

    '''
    
    theta_bar = theta_wted_sum(theta_dict, wt_dict)
    wt_sum = get_wt_sum(wt_dict)
    theta_var = get_theta_var(wt_sum)
    theta_bar = theta_var @ theta_bar
        
    return theta_bar, theta_var, wt_sum


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