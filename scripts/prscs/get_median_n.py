import pandas as pd
import argparse

## get median n for use in prscs

parser=argparse.ArgumentParser()
parser.add_argument('--sumstats', type=str, 
                    help='''Path to the meta sumstats''')
parser.add_argument('--effect', type=str, 
                    help='''Direct or population effect''')
parser.add_argument('--pheno', type=str, 
                    help='''Phenotype name''')
args=parser.parse_args()

# read in file
sumstats = pd.read_csv(args.sumstats, sep = " ")

# get median n
median_n = str(int(sumstats[f"{args.effect}_N"].median()))

# save to txt file
with open(f"/var/genetics/proj/within_family/within_family_project/processed/prscs/{args.pheno}/{args.effect}/{args.effect}_median_n.txt", "w") as text_file:
    text_file.write(f"{median_n}")
