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

- ```{sample}.metrics.tsv``` : A tab-delimited list of (Statistic, Value) pairs of all statistics and metrics recorded.
- ```{sample}.exon_reads.gct``` : A tab-delimited GCT file with (Exon ID, Gene Name, coverage) tuples for all exons which had at least part of one read mapped.
- ```{sample}.gene_reads.gct``` : A tab-delimited GCT file with (Gene ID, Gene Name, coverage) tuples for all genes which had at least one read map to at least one of its exons. This file contains the gene-level read counts used, e.g., for differential expression analyses.
- ```{sample}.gene_tpm.gct``` : A tab-delimited GCT file with (Gene ID, Gene Name, TPM) tuples for all genes reported in the gene_reads.gct file, with expression values in transcript per million (TPM) units.
- ```{sample}.fragmentSizes.txt``` : A list of fragment sizes recorded.
- ```{sample}.gene_fragments.gct``` : Number of fragment sizes per gene.


With coverage, an additional file are outputted:
- ```{sample}.coverage.tsv``` : A tab-delimited list of (Gene ID, Transcript ID, Mean Coverage, Coverage Std, Coverage CV) tuples for all transcripts encountered in the GTF.
- ```{samplename}.coverage.hgnc.tsv``` : Annotated coverage tsv file using ref_annot.gtf from the CTAT bundle.


## This app was made by East GLH