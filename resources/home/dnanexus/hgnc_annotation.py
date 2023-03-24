import pandas as pd
import argparse


def parse_args():
    """Parse through arguments
    Returns:
        args: Variable that you can extract relevant arguments from
        command line to set off.
    """
    # Read in arguments
    parser = argparse.ArgumentParser()

    parser.add_argument(
        '-hgnc', '--hgnc_file',
        help='HGNC complete static file, tab-separated',
        required=True
        )

    parser.add_argument(
       '-c', '--cov_metrics_file',
        help='Coverage metrics file outputted from RNA-SeQC',
        required=True
        )

    args = parser.parse_args()

    return args


def main():

    args = parse_args()

    # load coverage data
    dat = pd.read_csv(args.cov_metrics_file, sep = "\t")
    # remove ensembl gene versions
    dat['gene_id'] = dat['gene_id'].str.split('.').str[0]

    # load hgnc file
    hgnc_df = pd.read_csv(args.hgnc_file, sep = "\t",dtype='unicode')
    # make mapping dictionary
    ensembl_hgncid = dict(zip(hgnc_df.ensembl_gene_id, hgnc_df.hgnc_id))
    ensembl_hgncsymbol = dict(zip(hgnc_df.ensembl_gene_id, hgnc_df.symbol))

    # if ensembl gene ids match, copy over hgnc id and symbol to dat
    dat['hgnc_symbol'] = dat['gene_id'].apply(
                                    lambda x: ensembl_hgncsymbol.get(str(x))
                                   )
    dat['hgnc_id'] = dat['gene_id'].apply(
                                        lambda x: ensembl_hgncid.get(str(x))
                                    )
    # reorder columns
    dat = dat[['hgnc_symbol', 'hgnc_id', 'gene_id', 'coverage_mean',
                'coverage_std', 'coverage_CV']]

    # output string name
    output_filename = args.cov_metrics_file.replace('.tsv','.hgnc.tsv')
    # save file
    dat.to_csv(
        output_filename,
        sep="\t", index=False, header=True
        )


if __name__ == "__main__":

    main()