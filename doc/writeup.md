---
title: Meta Analyzing Family Based GWAS
subtitle: Everything Done So Far
---

# Cohorts And Phenotypes

| Cohohort | Phenotype | LDSC Test | Diag Plots and Tables | Notes |
| -------- | --------- | ------------------- | ----- | ------------ |
| STR | BMI | No (h2 estimate is negative) | ||
| STR | EA | Yes | |  |
| Hunt | EA | Yes | |  |
| GS | EA | Yes | |  |
| GS | BMI | Yes | |  |
| Finnish Twins | EA| No (Negative h2 estimate) | | |
| Finnish Twins | BMI | Yes | | |
| Estonian Biobank | BMI | Yes | | |
|Estonian Biobank | MDD | Yes | |  | 
| Estonian Biobank | Ever Smoker | No (-ve 1) | | |
| UKB | BMI | Yes | | |
| UKB | EA | Yes | | |
| MOBA | BMI | Yes | | |
| MOBA | Height | Yes | | |
| MOBA | Depressive symptoms | No  (h2 is negative) | | |
| MOBA | Income | No (h2 is negative) | | |
| MOBA | Fertility | No (Low power. h2 is negative sometimes in jack knife) | | |
|Geisinger| BMI | Yes | | |
| Geisinger | Height | Yes | | |
| Geisinger | Depression | Yes (Borderline rg) | | |
| Geisinger | EA | Yes | | |
| Geisinger | Smoke-Ever | No ( -ve 1) | | |
| Geisinger | Asthma | Yes | | |
|


# Analysis

## Meta analysis

The actual meta analysis comes first. It is done using `/var/genetics/proj/within_family/within_family_project/scripts/package/run_metaanalysis.py`. It is meant to be used as a command line tool. Its useful to go through how to use it since it isn't very straightforward,

### Options

As a command line tool it has only a few options which we shall explore:

1. `path2json` - This is the first positional argument and you'll need to pass in a json file into this. We will see what this json file should look like but for now its enough to know that the json file lists all the cohorts you want to pass in along with cohort specific options.
2. `--outestimates` - 