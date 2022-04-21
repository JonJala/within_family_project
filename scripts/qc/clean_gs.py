'''
Cleans Generation Scotland Data
by adding a clear chromosome 
column under "bim"
'''
import numpy as np
import pandas as pd
import glob
import h5py

import sys
sys.path.append('/var/genetics/proj/within_family/within_family_project/scripts/package/qc')
from easyqc_parsedata import *

# make chromosome column fine
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


# Make info files clean
infopath = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/info/chr*.info.gz"
infofiles = glob.glob(infopath)
infodat = pd.DataFrame(columns = ["SNP", "Rsq"])

for infofile in infofiles:
    dattmp = pd.read_csv(
        infofile,
        delim_whitespace = True
    )

    infodat = infodat.append(dattmp, ignore_index=True)


infodat[['CHR', 'BP', 'a1', 'a2']] = infodat['SNP'].str.split(":", expand=True)
infodat[['CHR', 'BP']] = infodat[['CHR', 'BP']].astype(int)
rsidfiles = "/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/SNPs/chr_*_rsids.txt"
chr_pos = 0
bppos = 3
rsidpos = 1
file_sep = " "

rsidfiles = glob.glob(rsidfiles)
snps = pd.DataFrame(columns = ["BP", "rsid"])
for file in rsidfiles:
    snp_i = return_rsid(file, chr_pos, bppos, rsidpos, file_sep)
    snps = snps.append(snp_i, ignore_index = True)

snps = snps.drop_duplicates(subset=['CHR', 'BP'])
infodat = pd.merge(infodat, snps, how = "inner", on = ['CHR', 'BP'])
infodat = infodat.drop('SNP', axis = 1)
infodat = infodat.rename(columns = {"rsid" : "SNP"})

infodat.to_csv(
    '/var/genetics/data/gen_scotland/public/latest/raw/sumstats/fgwas/info/combined_clean.info.gz',
    sep = "\t",
    index = False
)

