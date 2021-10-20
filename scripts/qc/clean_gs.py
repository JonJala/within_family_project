'''
Cleans Generation Scotland Data
by adding a clear chromosome 
column under "bim"
'''
import numpy as np
import pandas as pd
import glob
import h5py

for i in range(1, 15):
    
    print(i)
    files = glob.glob(f"/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/{i}/chr_*.hdf5")
    for file in files:
        hf = h5py.File(file, 'r')
        metadata = np.array(hf['bim'])
        chr_bp = metadata[:, 1]
        chr_bp = pd.Series(chr_bp.astype(str)).str.split(":", expand = True)
        chromosome = chr_bp.iloc[:, 0].values
        bp = chr_bp.iloc[:, 1].values
        metadata[:, 0] = chromosome

        hf_write = h5py.File(file[:-5] + "chr_clean.hdf5", 'w')
        hf_write.create_dataset('bim', data=metadata)
        hf_write.create_dataset('estimate', data=np.array(hf['estimate']))
        hf_write.create_dataset('estimate_cols', data=np.array(hf['estimate_cols']))
        hf_write.create_dataset('estimate_covariance', data=np.array(hf['estimate_covariance']))
        hf_write.create_dataset('estimate_ses', data=np.array(hf['estimate_ses']))
        hf_write.create_dataset('freqs', data=np.array(hf['freqs']))
        hf_write.create_dataset('sigma2', data=np.array(hf['sigma2']))
        hf_write.create_dataset('tau', data=np.array(hf['tau']))
        hf_write.close()
        hf.close()