---
title: Meta Analyzing Family Based GWAS
subtitle: Everything Done So Far
---

# Cohorts And Phenotypes

| Cohohort | Phenotype | LDSC Test | Diag Plots and Tables | Notes |
| -------- | --------- | ------------------- | ----- | ------------ |
| STR | BMI | No (h2 estimate is negative) | | |
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
| Geisinger | BMI | Yes | | |
| Geisinger | Height | Yes | | |
| Geisinger | Depression | Yes (Borderline rg) | | |
| Geisinger | EA | Yes | | |
| Geisinger | Smoke-Ever | No ( -ve 1) | | |
| Geisinger | Asthma | Yes | | |
| Lifeline | BMI/BMI18 | Yes | Yes | |
| Lifeline | Height/Height18 | Yes | Yes | |


# Analysis

## Meta analysis

The actual meta analysis comes first. It is done using `/var/genetics/proj/within_family/within_family_project/scripts/package/run_metaanalysis.py`. It is meant to be used as a command line tool. Its useful to go through how to use it since it isn't very straightforward,

### Options

As a command line tool it has only a few options which we shall explore:

1. `path2json` - This is the first positional argument and you'll need to pass in a json file into this. We will see what this json file should look like but for now its enough to know that the json file lists all the cohorts you want to pass in along with cohort specific options.
2. `--outestimates` - 


## Constructing A Matrix

(Might automate this later on)

An A matrix is required to be provided for each cohort. We will now go into how you should construct these matrices. Remember all vectors are thought of as column vectors here.

- You need to know what effects you have for a given cohort (like direct plus average parental, or a full set of direct, paternal and maternal effects, etc). Lets name this "base effects".
- You will need to know to what kind of effect you want to convert this effect to. Lets name this "target effects". This is what the final metanalyzed effects will be.
- The A matrix will need to satisfy the equation $baseeffect = A \cdot targeteffect$

The number of rows the A matrix will have will correspond to the number of effects your cohort has estimated. The number of columns will correspond to the number of effects you want to get to at the end.

For example:
- Lets say our cohort has direct and average parental effects
- We want our meta analysis to output meta analyzed estimates for direct, paternal and maternal effects
- Our A matrix will be:
$$
\begin{bmatrix}
1 \ 0  \ 0 \\
0 \ 0.5 \ 0.5
\end{bmatrix}
$$
