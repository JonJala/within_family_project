import numpy as np
import h5py

parental_id_out = np.empty((0, 2), int)
for chromosome in range(1, 23):
    print(f'Reading chromosome {chromosome}')
    filepath = f"/disk/genetics/ukb/alextisyoung/hapmap3/haplotypes/imputed/chr_{chromosome}.hdf5"
    with h5py.File(filepath, 'r') as hf:
        pedigree = np.array(hf['pedigree'])
        pedigree_names = pedigree[0, :].astype(str)
        pedigree_vals = pedigree[1:, :].astype(str)

        mother_id_idx = np.isin(pedigree_names, 'MOTHER_ID')
        father_id_idx = np.isin(pedigree_names, "FATHER_ID")
        father_mother_id = np.where(father_id_idx | mother_id_idx)[0].tolist()

        hasmom_idx = np.isin(pedigree_names, "has_mother")
        hasdad_idx = np.isin(pedigree_names, "has_father")

        hasdad = (pedigree_vals[:, hasdad_idx] == 'True').flatten()
        hasmom = (pedigree_vals[:, hasmom_idx] == 'True').flatten()

        pedigree_hasparents = pedigree_vals[hasmom & hasdad, :]
        parental_id = pedigree_hasparents[:, father_mother_id].astype(int)

        parental_id_out = np.vstack((parental_id_out, parental_id))


# output has to be fid and id, but ukb fid == id
parental_id_out = np.unique(parental_id_out, axis = 0) 
father_id_out = parental_id_out[:, 0]
mother_id_out = parental_id_out[:, 1]
n = father_id_out.shape[0]

father_fid_out = father_id_out
mother_fid_out = mother_id_out

father_sex = 1
mother_sex = 2

missing = np.zeros(n, int)

col_names = np.array(['ID_1', 'ID_2', 'missing', 'sex'])
col_types = np.array(['0', '0', '0', 'D'])

father_out = np.vstack((father_fid_out, father_id_out, missing, np.repeat(father_sex, n))).T
father_out = np.vstack((col_names, col_types, father_out))

mother_out = np.vstack((mother_fid_out, mother_id_out, missing, np.repeat(mother_sex, n))).T
mother_out = np.vstack((col_names, col_types, mother_out))

crosswalk_header = np.array(['father_id', 'mother_id'])
parental_id_out = np.vstack((crosswalk_header, parental_id_out))

np.savetxt('/var/genetics/proj/within_family/within_family_project/processed/ldpred2/father.sample', father_out, fmt='%s')
np.savetxt('/var/genetics/proj/within_family/within_family_project/processed/ldpred2/mother.sample', mother_out, fmt='%s')
np.savetxt('/var/genetics/proj/within_family/within_family_project/processed/ldpred2/father.fam', father_out[2:, 0:2], fmt='%s')
np.savetxt('/var/genetics/proj/within_family/within_family_project/processed/ldpred2/mother.fam', mother_out[2:, 0:2], fmt='%s')
np.savetxt('/var/genetics/proj/within_family/within_family_project/processed/ldpred2/spousal_crosswalk', parental_id_out, fmt = '%s')









