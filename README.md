# eggd_RNASeQC

## What does this app do?

RNA-SeQC ([RNA-SeQC 2: efficient RNA-seq quality control and quantification for large cohorts](https://academic.oup.com/bioinformatics/article/37/18/3048/6156810?login=false))  is a powerful tool that generated over 70 metrics. It quantifies gene- and exon-level expression, enabling effective quality control of RNA datasets

## What inputs are required for this app to run?

- ```bam``` - bam file
- ```CTAT bundle``` - A CTAT genome library, which contains the ref_annot.gtf file needed to annotate the genes and transcripts for coverage metrics.
- ```bed``` - bed file with 6 columns; chrom, start and end, name, score and strand
- ```docker``` - docker input that contains the RNA-SeQC tool.
- ```coverage``` - boolean for whether coverage metrics should be calculated or not. Default is true.


## How does this app work?

The app inputs the bam, CTAT bundle and bed file. The CTAT bundle is unpacked and the ref_annot.gtf is collapsed format (combining all isoforms of a gene into a single transcript) so RNA-SeQC is able to calculate the QC metrics.

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
- ```{samplename}.coverage.hgnc.tsv```


## This app was made by East GLH