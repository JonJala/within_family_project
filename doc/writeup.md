---
title: Meta Analyzing Family Based GWAS
subtitle: Everything Done So Far
---

# Cohorts And Phenotypes

| Cohohort | Phenotype | LDSC Test | Diag Plots and Tables | Notes |
| -------- | --------- | ------------------- | ----- | ------------ |
| STR | BMI | No (h2 estimate is negative) | Yes | |
| STR | EA | Yes |  Yes |  |
| Hunt | EA | Yes | Yes |  |
| Hunt | AAFB | Yes | | |
| Hunt | N Children | No (too low rg) | | |
| Hunt | Drinks Per Week | No (rg = -1) | | |
| Hunt | Height | Yes | Yes | |
| Hunt | Neuoriticism | Yes | | |
| Hunt | Self Rated Health | 
| GS | EA | Yes | Yes |  |
| GS | BMI | Yes | Yes |  |
| Finnish Twins | EA| No (Negative h2 estimate) | Yes | |
| Finnish Twins | BMI | Yes | Yes | |
| Estonian Biobank | BMI | Yes | Yes | |
| Estonian Biobank | MDD | Yes | |  | 
| Estonian Biobank | Ever Smoker | No (-ve 1) | | |
| Estonian Biobank | AAFB | Yes | | |
| Estonian Biobank | Asthma | Yes | | |
| Estonian Biobank | Depression | Yes | Yes | |
| Estonian Biobank | Eczema | Yes | | |
| Estonian Biobank | Hayfever | | | |
| UKB | BMI | Yes | Yes | |
| UKB | EA | Yes | Yes | |
| MOBA | BMI | Yes | Yes | |
| MOBA | Height | Yes | Yes | |
| MOBA | Depressive symptoms | No  (h2 is negative) | | |
| MOBA | Income | No (h2 is negative) | | |
| MOBA | Fertility | No (Low power. h2 is negative sometimes in jack knife) | | |
| Geisinger | BMI | Yes | Yes | |
| Geisinger | Height | Yes | Yes | |
| Geisinger | Depression | Yes | Yes | |
| Geisinger | EA | Yes | Yes | |
| Geisinger | Smoke-Ever | No ( -ve 1) | | |
| Geisinger | Asthma | Yes | | |
| Lifeline | BMI/BMI18 | Yes | Yes | |
| Lifeline | Height/Height18 | Yes | Yes | |
|  Minnesotta twins | EA | Yes | Yes | |
|  Minnesotta twins | BMI | Yes | Yes | |
|  Minnesotta twins | Height | Yes | Yes | | 
|  Minnesotta twins | BPS | | | |
| Minnesotta twins | CPD | No | | |
| Minnesotta twins | DPW | No | | |
| Minnesotta twins | ES | No | | |
| Minnesotta twins | Income | No | | |
| Minnesotta twins | IQ | | | |
| Minnesotta twins | Stress | | | |
| Minnesotta twins | SWB | | | |



# Analysis

## Meta analysis

The actual meta analysis comes first. It is done using `/var/genetics/proj/within_family/within_family_project/scripts/package/run_metaanalysis.py`. It is meant to be used as a command line tool. Its useful to go through how to use it since it isn't very straightforward,

### Options

As a command line tool it has only a few options which we shall explore:

1. `path2json` - This is the first positional argument and you'll need to pass in a json file into this. We will see what this json file should look like but for now its enough to know that the json file lists all the cohorts you want to pass in along with cohort specific options.
2. `--outestimates` - This is what the final output should look like. You should write down something like "direct_plus_averageparental" or "direct_plus_population". Note that for now the default is direct_plus_population and the script might not work well if its something different - especially if the output is expected to be more than a 2 dimensional output.
3.  `--outprefix` - This just defines where the output should be saved and what they should be saved as.
4. `--no_hdf5_out` and `--no_txt_out` - These are indicators to disable either outputting the hdf5 file or the txt file. You can put in both but then nothing will be outputted from the script.
5. `--diag` - This is an option which if passed will also produce diagnostic plots and summary statistics for every cohort passed. Not entirely recommended as it is a bit slow. You should use the diagnostics script for this.

These options are not the entire list of options available. `path2json` is the path to the json file listing all the input files and also putting in options for each input. This is more complicated and also important so its worth going into.


