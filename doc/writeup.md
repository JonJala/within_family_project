---
title: Meta Analyzing Family Based GWAS
subtitle: Everything Done So Far
---

# Cohorts And Phenotypes

*Need to fill this out*

# Analysis

## Meta analysis

The actual meta analysis comes first. It is done using `/var/genetics/proj/within_family/within_family_project/scripts/package/run_metaanalysis.py`. It is meant to be used as a command line tool. Its useful to go through how to use it since it isn't very straightforward,

### Options

As a command line tool it has only a few options which we shall explore:

1. `path2json` - This is the first positional argument and you'll need to pass in a json file into this. We will see what this json file should look like but for now its enough to know that the json file lists all the cohorts you want to pass in along with cohort specific options.
2. `--outestimates` - 