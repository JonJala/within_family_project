import numpy as np
import pandas as pd
from numba import jit, njit, prange


@njit(cache = True, fastmath = True)
def fastmode(a):
 
    # variable to store max of
    # input array which will
    # to have size of count array
    n = a.shape[0]
    max_element = max(a)
 
    # auxiliary(count) array to store count.
    # Initialize count array as 0. Size
    # of count array will be equal to (max + 1).
    t = max_element + 1
    count = np.zeros(t)
 
    # Store count of each element
    # of input array
    for i in range(n):
        if a[i] > -1: #-1 is missing value
            count[a[i]] += 1
 
    # mode is the index with maximum count
    mode = 0
    k = count[0]
    for i in prange(1, t):
        if (count[i] > k):
            k = count[i]
            mode = i
         
    return mode



@njit(parallel = True, cache = True, fastmath = True)
def fastmode_mult(a):
    '''
    Put in multidimensional array
    to get mode of every row
    '''
    
    n = a.shape[0]
    
    mode_arr = np.zeros(n)
    
    for i in prange(n):
        mode_arr[i] = fastmode(a[i, :])
        
    return mode_arr

def str_to_int(dfin):
    '''
    Converts a pandas dataframe of only
    strings to a numpy matrix of integers.
    
    Returns:
    outmat - matrix of integers
    lookuptable - array of unique strings in dataset.
    Can recover original dataset in matrix form by using
    `lookuptable[outmat]`
    '''
    
    n, m = dfin.shape
    
    df = dfin.fillna('ZZZ')
    
    amat = df.values
    noneidx = np.where(amat == 'ZZZ')
    amat = amat.astype(str)

    lookuptable, indexed_dataset = np.unique(amat, return_inverse=True)
    
    outmat = indexed_dataset.reshape((n, m))
    outmat[noneidx] = -1
    
    return outmat, lookuptable


def calc_str_mode(df):
    
    amat, lookuptable = str_to_int(df)
    amode_idx = fastmode_mult(amat)
    amode = lookuptable[amode_idx.astype(int)]
    
    return amode