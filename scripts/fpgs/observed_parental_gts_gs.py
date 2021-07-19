import pandas as pd
import numpy as np
import h5py
import glob

impfiles = "/disk/genetics/sibling_consortium/GS20k/alextisyoung/HM3/imputed_phased/chr_~.hdf5"
impfiles = impfiles.split("~")
idfile_out = np.empty((0, 2), int)

for chr in range(1, 23):
    impfile = impfiles[0] + str(chr) + impfiles[1]
    print("reading file: ", impfile)
    with h5py.File(impfile, 'r') as hf:
        pedigree = np.array(hf['pedigree']) 
        pedigree_names = pedigree[0, :].astype(str)
        pedigree_vals = pedigree[1:, :].astype(str)
        
        fid_idx = np.where(pedigree_names =='FID')[0][0]
        iid_idx = np.where(pedigree_names == 'IID')[0][0]
        hasmom_idx = np.isin(pedigree_names, "has_mother")
        hasdad_idx = np.isin(pedigree_names, "has_father")
        
        hasdad = (pedigree_vals[:, hasdad_idx] == 'True').flatten()
        hasmom = (pedigree_vals[:, hasmom_idx] == 'True').flatten()
        
        pedigree_hasparents = pedigree_vals[hasmom & hasdad, :]
        
        ids_bothparents = pedigree_hasparents[:, [fid_idx, iid_idx]].astype(int)

        print(ids_bothparents)
        idfile_out = np.vstack((idfile_out, ids_bothparents))

np.savetxt('/var/genetics/proj/within_family/within_family_project/processed/fpgs/observed_gts_gs/observed_gts_gs.fam', idfile_out, fmt='%s')
    