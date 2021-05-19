import numpy as np
import pandas as pd
import datetime as dt


def dataframe_diagnostics(df):
    
    return f"Data shape = {df.shape}, SNP NAs = {df['SNP'].isna().sum()}"
    
    
def logdf(f):
    def wrapper(*args, **kwargs):
        tic = dt.datetime.now()
        result = f(*args, **kwargs)
        toc = dt.datetime.now()
        print(f"{f.__name__} took {toc - tic}. {dataframe_diagnostics(result)}")
        return result
    return wrapper
        
    
    
@logdf
def begin_pipeline(df):
    
    return df.copy()