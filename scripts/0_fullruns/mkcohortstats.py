import pandas as pd
import glob
from os.path import exists

#------------------------------------------------------------------------------------------------------
# Compile Supplementary Table 2
#------------------------------------------------------------------------------------------------------

basepath = '/var/genetics/proj/within_family/within_family_project/'
qcfolders = glob.glob(basepath + 'processed/qc/*')
datout = pd.DataFrame(columns = ['Cohort', 'Phenotype', 'direct_n_median_hm3', 'population_n_median_hm3', 'N_SNP_preqc', 'N_SNP_postqc', 'Genetic Correlation', 'Genetic Correlation SE'])
hm3 = pd.read_csv('/disk/genetics2/pub/data/PH3_Reference/w_hm3.snplist', delim_whitespace=True)

for qcfolder in qcfolders:
    cohort = qcfolder.split('/')[-1]
    cohort = cohort.title()
    phenotypes = glob.glob(qcfolder + '/*')
    for phenotype in phenotypes:
        phenotypename = phenotype.split('/')[-1].title()
        print(f'Reading directory:\t {phenotype}')

        # Median effective N
        if exists(phenotype + '/CLEANED.out.gz'):
            dat = pd.read_csv(
                phenotype + '/CLEANED.out.gz',
                delim_whitespace=True
            )
            dat = dat[dat['SNP'].isin(hm3['SNP'])]
            ndirect_median = dat['n_direct'].median()
            npopulation_median = dat['n_population'].median()
        else:
            ndirect_median = None
            npopulation_median = None
        # Reference LDSC
        if exists(phenotype + '/refldsc.log'):
            with open(phenotype + '/refldsc.log') as f:
                ldscfile = f.readlines()
                nfile = len(ldscfile)
                rglist = [rg for rg in ldscfile if rg.startswith('Genetic Correlation:')]
                if len(rglist) > 0:
                    rgline = rglist[0]
                    rg = rgline.split(':')[1]
                    rgest = float(rg.split('(')[0])
                    rgse = float(rg.split('(')[1].replace(')', '').replace('\n', ''))
                else:
                    rgest = None
                    rgse = None


        if exists(phenotype + '/clean.rep'):
            dat = pd.read_csv(phenotype + '/clean.rep', delim_whitespace=True)
            nsnpin = dat['numSNPsIn'].values[0]
            nsnpout = dat['numSNPsOut'].values[0]
        else:
            nsnpin = None
            nsnpout = None
            
        
        dattmp = pd.DataFrame({
            'Cohort' : [cohort],
            'Phenotype' : [phenotypename],
            'direct_n_median_hm3' : [ndirect_median],
            'population_n_median_hm3': [npopulation_median],
            'N_SNP_preqc' : [nsnpin],
            'N_SNP_postqc' : [nsnpout],
            'Genetic Correlation' : [rgest],
            'Genetic Correlation SE' : [rgse]
        })
        datout = datout.append(dattmp, ignore_index=True)

datout = datout.loc[datout['Cohort'] != 'Ea4', :]
datout = datout.loc[datout['Cohort'] != 'Otherqc']

## reformat / captitalize

# cohort names
datout.replace("Estonian_Biobank", "Estonian Biobank", inplace=True)
datout.replace("Ukb", "UKB", inplace=True)
datout.replace("Minn_Twins", "Minn Twins", inplace=True)
datout.replace("Gs", "GS", inplace=True)
datout.replace("Moba", "MOBA", inplace=True)
datout.replace("Str", "STR", inplace=True)
datout.replace("Ft", "FT", inplace=True)
datout.replace("Ipsych", "iPSYCH", inplace=True)
datout.replace("Dutch_Twin", "Dutch Twin", inplace=True)
datout.replace("Qimr", "QIMR", inplace=True)
datout.replace("Fhs", "FHS", inplace=True)
datout.replace("Ckb", "CKB", inplace=True)
datout.replace("Finngen", "FinnGen", inplace=True)

# phenotypes
datout.replace("Cho18", "CHO18", inplace=True)
datout.replace("Bmi", "BMI", inplace=True)
datout.replace("Ldl18", "LDL18", inplace=True)
datout.replace("Hdl18", "HDL18", inplace=True)
datout.replace("Ldl", "LDL", inplace=True)
datout.replace("Hdl", "HDL", inplace=True)
datout.replace("Tgl", "TGL", inplace=True)
datout.replace("Ea", "EA", inplace=True)
datout.replace("Tgl18", "TGL18", inplace=True)
datout.replace("Bmi18", "BMI18", inplace=True)
datout.replace("Mdd", "MDD", inplace=True)
datout.replace("Aafb", "AAFB", inplace=True)
datout.replace("Aud", "AUD", inplace=True)
datout.replace("Copd", "COPD", inplace=True)
datout.replace("Bpd", "BPD", inplace=True)
datout.replace("Adhd", "ADHD", inplace=True)
datout.replace("Bps", "BPS", inplace=True)
datout.replace("Cpd", "CPD", inplace=True)
datout.replace("Fev", "FEV1", inplace=True)
datout.replace("Dpw", "DPW", inplace=True)
datout.replace("Swb", "SWB", inplace=True)
datout.replace("Nonhdl", "Non-HDL", inplace=True)
datout.replace("Ea_Years", "EA", inplace=True)

# export
datout.to_csv(
    basepath + 'processed/package_output/cohortstats.txt',
    index = False,
    sep = '\t'
)


