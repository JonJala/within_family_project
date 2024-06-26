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
datout.replace("Ukb", "UK Biobank", inplace=True)
datout.replace("Minn_Twins", "Minnesota Twins", inplace=True)
datout.replace("Gs", "Generation Scotland", inplace=True)
datout.replace("Moba", "Norwegian Mother, Father and Child Cohort Study (MoBa)", inplace=True)
datout.replace("Str", "Swedish Twin Registry", inplace=True)
datout.replace("Hunt", "Trøndelag Health Study (HUNT)", inplace=True)
datout.replace("Ft", "Finnish Twin Register", inplace=True)
datout.replace("Ipsych", "iPSYCH", inplace=True)
datout.replace("Dutch_Twin", "Netherlands Twin Register", inplace=True)
datout.replace("Qimr", "QIMR Berghofer Medical Research Institute (QIMR)", inplace=True)
datout.replace("Fhs", "Framingham Heart Study", inplace=True)
datout.replace("Ckb", "China Kadoorie Biobank", inplace=True)
datout.replace("Botnia", "Botnia Family Study", inplace=True)
datout.replace("Finngen", "Finngen", inplace=True)

# phenotypes
datout.replace("Cho18", "Total cholesterol at 18", inplace=True)
datout.replace("Cho", "Total cholesterol", inplace=True)
datout.replace("Bmi18", "BMI at 18", inplace=True)
datout.replace("Bmi", "BMI", inplace=True)
datout.replace("Gpahs", "High school GPA", inplace=True)
datout.replace("Gpa9", "GPA (9th grade)", inplace=True)
datout.replace("Height18", "Height at 18", inplace=True)
datout.replace("Cognition18", "Cognitive performance at 18", inplace=True)
datout.replace("Ldl18", "LDL cholesterol at 18", inplace=True)
datout.replace("Hdl18", "HDL cholesterol at 18", inplace=True)
datout.replace("Ldl", "LDL cholesterol", inplace=True)
datout.replace("Hdl", "HDL cholesterol", inplace=True)
datout.replace("Tgl18", "Triglycerides at 18", inplace=True)
datout.replace("Tgl", "Triglycerides", inplace=True)
datout.replace("Ea", "EA", inplace=True)
datout.replace("Hhincome", "Household income", inplace=True)
datout.replace("Mdd", "MDD", inplace=True)
datout.replace("Aafb", "Age at first birth (women)", inplace=True)
datout.replace("Aud", "Alcohol use disorder", inplace=True)
datout.replace("Copd", "COPD", inplace=True)
datout.replace("Bpd", "Blood pressure (diastolic)", inplace=True)
datout.replace("Adhd", "ADHD", inplace=True)
datout.replace("Bps", "Blood pressure (systolic)", inplace=True)
datout.replace("Cpd", "Cigarettes per day", inplace=True)
datout.replace("Fev", "FEV1", inplace=True)
datout.replace("Dpw", "Drinks per week", inplace=True)
datout.replace("Swb", "Subjective well-being", inplace=True)
datout.replace("Nonhdl", "Non-HDL cholesterol", inplace=True)
datout.replace("Ea_Years", "EA", inplace=True)
datout.replace("Eversmoker18", "Ever-smoker at 18", inplace=True)
datout.replace("Eversmoker", "Ever-smoker", inplace=True)
datout.replace("Agemenarche", "Age-at-menarche", inplace=True)
datout.replace("Depsymp", "Depressive symptoms", inplace=True)
datout.replace("Morningperson", "Morning person", inplace=True)
datout.replace("Nchildren", "Number of children", inplace=True)
datout.replace("Health", "Self-rated health", inplace=True)
datout.replace("Nearsight", "Myopia", inplace=True)
datout.replace("Income", "Individual income", inplace=True)
datout.replace("Cognition", "Cognitive performance", inplace=True)
datout.replace("Hayfever", "Allergic rhinitis", inplace=True)

# export
datout.to_csv(
    basepath + 'processed/package_output/cohortstats.txt',
    index = False,
    sep = '\t',
    na_rep = "NA"
)


