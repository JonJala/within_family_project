This document will go through all the steps of the within family pipeline. This won't go over the theoretical aspects of the project since that can be found in the supplementary note file on the dropbox folder. Instead this goes through the pipeline practically.

Assume the home directory we are on is the git repository for the within family project.

# Quality Control

The core quality control script can be found in `scripts/package/qc/run_easyqc.py`. This is a command line tool so should be called with options. The bash scripts which call this are located in `within_family_project/scripts/qc` with titles `runqc_<PHENOTYPENAME>.sh` Here are the common options:

1. filepath - This is the first positional argument which takes in a "globbed" file path of the family GWAS summary statistics. This could be in the hdf5 file format or the text delimited (and optionally compressed) format following the outputs of SNIPAR
2. --outprefix - Pass in the prefix to all the cleaned output you want
3. --effects - The set of effects estimated in the filepath file. Defualt is "direct_paternal_maternal"
4. --toest - The set of the effects we want the cleaned output to have.
5. --info - A text delimited file (can be compressed) which contains the columns SNP, Rsq and AvgCall corresponding to the rsids, INFO R-sqaured and Average call rate respectively. Its optional to pass this in
6. ---hwe - A text delimited file (can be compressed) which contains the columns SNP and P corresponding to the rsids and Hardy-Weinberg P values respectively.

The QC scripts in `scripts/qc` are divided by phenotype but the outputs are divided by cohort and can be found here: `processed/qc`.

The output directory will contain EasyQC outputs. The relevant datafile will be named "CLEANED.out.gz". Other files are diagnostic plots, and LDSC genetic correlation estimates. And important file is the `clean.rep` file which details how many SNPs are dropped at each stage of the QC.

# Meta Analysis

The core meta analysis script is located here: `scripts/package/run_metaanalysis.py`. It is a command line tool. The bash scripts calling this script are located here: `scripts/usingpackage` and are ordered by phenotype. Within each phenotype directory the file `runmeta.sh` is the script which calls the meta analysis script. 

To run the script one first needs a json file with the list of input data. The input data will be the `CLEANED.out.gz` output from the QC step. An example of this json file is here: `scripts/usingpackage/bmi/inputfiles.json`. You need to pass in each cohort name and alongside it the path to the QCed summary statistics of that cohort. *VERY IMPORTANT* that the cohort names here do not contain an underscore! So do not write "estonian_biobank". The cohort names aren't particularly important here but are useful for debugging.

Once you have the json file you need to pass it into the meta analysis command line tool.

The arguments the tool accepts are:

1. inputfilepath - This is a required positional argument. It is the path of the json files which lists all the input files
2. --outprefix - The prefix to the output.

The script outputs can be located here: `processed/package_output`. Output is sorted by phenotype, although each phenotype directory contains more than just the outputs of the meta analysis script (it also has outputs from the other sciprts in `scripts/usingpackage/<PHENOTYPE>/` directory).

# LDSC (and other secondary analyses)

After the meta analysis we run some LDSC scripts on the output. The scripts can be found in `scripts/usingpackage/<PHENOTYPE>/ldsc_analysis.sh`. This has to be copy pasted and modified for each new phenotype analysis added in. All output is stored in `processed/package_output`.

There are other scripts sometimes in the `scripts/usingpackage/<PHENOTYPE>/` directory. All output from those are stored in the `processed/package_output` directory as well.

# SBayesR

We estimate the PGI weights using SBayesR. 

The core bash script can be found here: `scripts/sbayesr/sbayesrfunc.sh`. This has the bash function which is called for each phenotype. For example here: `scripts/sbayesr/ea_pgi.sh`. The function is called `run_pgi` and takes in the summary statistics location, effect type (direct or population usually), phenotype name, and target cohort (can only be either MCS or UKB for now).

The function first formats the summary statistics in a way sbayesr can read. This is done using the scripts/sbayesr/format_gwas.py script.  And then sbayesr is run. The output is stored in `processed/sbayesr/<PHENOTYPE>/<EFFECT>/` by phenotype name and effect (direct or population usually). Log files are stored in `processed/sbayesr/logs`.

Output files include weights in the `processed/sbayesr/<PHENOTYPE>/<EFFECT>/weights` directory. The file of interest here is `meta_weights.snpRes`. These contain the SNP weights estimated by SbayesR.

The `processed/sbayesr/<PHENOTYPE>/<EFFECT>/` directory contains other useful files. `pgipred.regresults` contains the results of regressing the phenotype from the validation sample on the scores. We should expect the coefficient to be positive and the incremental $R^2$ to be moderately high (depending on the phenotype). You can also look at `.parentalcorr` to look at the estimated correlation of PGIs for observed parents. We dont expect this to be a particular way but they give an idea of assortative mating.


Finally you can see the final individual level scores constructed using the sbayesr weights and the genotype files in the relevant data folders. That would be `/var/genetics/data/mcs/private/latest/processed/proj/within_family/pgs/sbayesr` and `/var/genetics/data/ukb/private/v3/processed/proj/within_family/pgs/sbayesr`.

# Within Family PGI Regressions

Once we have the PGI weights from SbayesR we need to:

1. Compute family wise PGIs
2. Run within family regressions

Both these steps are taken care of by the `main` function in `scripts/fpgs/fpgipipeline_function.sh`. An example of a script calling the `main` function is `scripts/fpgs/fpgs_ea.sh`.

The `main` function is a bit involved.

First it calls another function created in the `fpgipipeline_function.sh` script called `withinfam_pred`. This function is called twice usually - once for using the direct effect summary statistics and once for the population effect summary statistics. The `withinfam_pref` function does a couple of things:

1. Formats the weights so that SNIPAR can read it
2.  Formats the phenotype file so that SNIPAR can read it
3.  Runs `pgs.py` (a script in your path if you install SNIPAR) to create the PGIs for each family (parental genotypes may or may not be imputed)
4.  Runs `attach_covar.py` to attach the coviariates to the family PGIs. Two sets are created - one with the proband PGI and the covariates and one with the full set of family PGIs and the covariates. This is because down the line, the proband set gives us the population coefficient and the family set gives us the direct coefficient.
5. Then we use the `fpgs_reg.py` script to run the within family regressions. This is run for the proband set and the full family set. The `fpgs_reg.py` script is slightly involved as well but the core idea is:
    - If the phenotype is binary then run a logit regression in python to get the coefficients out. Otherwise use `pgs.py` to get the coefficients out.
    - If the validation phenotype is UKB then run OLS for the unrelated individuals to get the $R^2$ but then run either logit or `pgs.py` to get the coefficients
    - The above two steps are chosen depending on the `ols`, `logistic` and `kin` arguments in `fpgs_reg.py`.

Once the `withinfam_pred` function is finished for each effect (direct and population) there are a couple of auxillary things the `main` function does.

1. Runs a covariates only regression using `fpgs_reg.py`. This is because the relevant $R^2$ measure we need finally is the incremental $R^2$ for which this regression has to be computed
2. Runs `bootstrapest.py`. This is to calculate the direct/population coefficient ratio and its standard error via bootstrap. It also computes the difference between the direct/population ratio from the direct effects summary statistics and the population effect summary statistics and the SE of that estimate using bootstrap, but this isn't reported or used (yet!). 

# Compiling Results

Results are compiled using `scripts/0_fullruns/compile_results.py`. It is a slightly lengthy and tedious script because it compiles results from the previous steps and formats them so that it can be easily copy-pasted into the supplementary tables. It creates three outputs - `meta.results`, `fpgs.results` and `direct_population_rg_matrix`. These are stored in `processed/package_output`.

Note that there is also a script `/scripts/0_fullruns/fullruns.sh`. This runs all the analyses detailed until now for each phenotype. 

# Things to potentially change or tweak

## SbayesR

- We filter the summary statistics on median effective N of each summary statistic before passing it into SbayesR. This results in half the SNPs being dropped. This ensures SbayesR converges but because we lose too many SNPs there might be another way to do this more effectively. EA4 uses $0.8 \cdot \text{Effective N}$. But this threshold is too low for some of the phenotypes we have like HDL. You can vary this threshold by looking into the `scripts/sbayesr/sbayesrfunc.sh` script, going into the `run_pgi` function and looking at where we call `format_gwas.py`. 

## Within Family Regressions

- The way we compute $R^2$ should be changed to something like nagelkerke's $R^2$ so that results for logistic and OLS are comparable. Look into the `fpgs_reg.py` script in the `scripts/fpgs` directory to change this.

## Compiling Results

- Probably need to modify things here as new analyses and tweaks are made

# Other Analyses

These are analyses which aren't yet part of the main pipeline but might be useful.

## Lead SNPs 

The idea here is to get a set of SNPs which are the SNPs with the highest effective N within each segment we create. 

Segments are created using this script: `scripts/genetic_mapping/rungeneticmapping.sh` which calls on the script `scripts/genetic_mapping/makegeneticmap.py`. We use the genetic map found here: `snipar/snipar/util_data/decode_map/chr_~.gz` We aim to create 1 million segments using these steps:

1. First get the length of each segment needed. This will simply be the sum of all the lengths of segments divided by the target number of segments (1 million in this case)
2. Make a variable called `segmentlengthtillnow`. Set `snpstartidx` to 0. Then loop through SNPs:
    - Add the segment length to `segmentlengthtillnow`.
    - If `segmentlengthtillnow` < target segment length then continue to next snp. Else, keep all snps from `snpstartidx` to current SNP index into current segment. Set `segmentlengthtillnow` to 0 again, and set `snpstartidx` to current SNP index



As it stands we only get ~300k SNPs/segments eventhough we were expecting to get 1 million. This is likely because there are a lot of SNPs (~180k) with segment sizes magnitudes larger than our target segment size. This would reduce the number of segments by a third or a fourth.



