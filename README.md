# eggd_RNASeQC

## What does this app do?

RNA-SeQC (RNA-SeQC 2: efficient RNA-seq quality control and quantification for large cohorts[https://academic.oup.com/bioinformatics/article/37/18/3048/6156810?login=false])  is a powerful tool that generated over 70 metrics. It quantifies gene- and exon-level expression, enabling effective quality control of RNA datasets

## What inputs are required for this app to run?

- ```bam``` - bam file
- ```gtf``` - GTF file containing features to check the bam against. This file should be collapsed so there there are no overlapping transcripts on the same strand and that each gene have a single transcript whose id matches the parent gene id.
- ```bed``` - bed file containg chromosome, start and end
- ```coverage``` - boolean for whether coverage metrics should be calculated or not
- ```docker``` - Docker input that contains the RNA-SeQC tool


## How does this app work?

The app inputs the bam, gtf and bed file and calculates QC metrics using RNA-SeQC.

## What does this app output?

Without the coverage the outputs are:

- ```{samplename}.exon_csv.tsv```
- ```{samplename}.exon_reads.gct```
- ```{samplename}.fragmentSizes.txt```
- ```{samplename}.gene_fragments.gct```
- ```{samplename}.gene_reads.gct```
- ```{samplename}.gene_tpm.gct```
- ```{samplename}.metrics.tsv```

With coverage, an additional file are outputted:
- ```{samplename}.coverage.tsv```


## This app was made by East GLH