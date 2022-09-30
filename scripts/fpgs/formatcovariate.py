'''
Python script to format covariate file
'''
import pandas as pd

covar = pd.read_csv(
    '/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar.txt',
    delim_whitespace=True 
)

covar.to_csv(
    '/var/genetics/data/mcs/private/latest/raw/gen/NCDS_SFTP_1TB_1/imputed/phen/covar_noheader.txt',
    sep=" ",
    index=False,
    header=False
)
