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
        '-g', '--gtf_file',
        help='ref_annot.gtf file from CTAT bundle',
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

    # load hgnc file
    ref_flat = pd.read_csv(args.gtf_file,
                            sep = "\t", skiprows = 5,
                            header=None,
                            names = ['chr', 'source', 'feature',
                                    'start','end', 'score', 'strand',
                                    'frame','attribute'
                            ]
                        )
    # select the needed columns to save space
    ref_flat = ref_flat[['chr', 'source', 'feature', 'start','end', 'attribute']]
    ref_flat = ref_flat[ref_flat['feature'] == "gene"]
    # the attributes columns has a lot of information about the transcript,
    # split these by semi colon seperators
    ref_flat2 = pd.concat(
        [ref_flat, ref_flat['attribute'].str.split('; ', expand=True)],axis=1
        ).drop('attribute', axis=1)
    # attributes has no titles, but we are intersted in columns 5,7,9 which
    # is the gene ID, hgnc symbol and hgnc ID
    # +---------------------------------------------------------+----------------------------------------------------------------+
    # |  chr | source | feature | start | end | 0 | ...  | 3 | 4 | 5 | 6 | 7 | 8 |
    # +=======================================================================+=======================================================================================+
    # | chr1 | HAVANA | gene | 11869 | 14409 | gene_id "ENSG00000223972.5" | ... | level 2 | hgnc_id "HGNC:37102" | havana_gene "OTTHUMG00000000961.2" | None | None | None |
    # +--------------------------------------------------------+-----------------------------------------------------------------+

    ref_flat2 = ref_flat2.iloc[:, [5,7,9]]
    ref_flat2.columns =['ENSG_ID', 'hgnc_symbol', 'HGNC_ID']

    # the elements in these columns have a header "gene_id" for example
    # in it and we dont want these so we will scrap it and also remove
    # the qoutes around the element
    ref_flat2['ENSG_ID'] = ref_flat2['ENSG_ID'].str.split('gene_id').str[1]
    ref_flat2['ENSG_ID'] = ref_flat2['ENSG_ID'].str.replace(r'"', '', regex=True)
    ref_flat2['hgnc_symbol'] = ref_flat2['hgnc_symbol'].str.split('gene_name').str[1]
    ref_flat2['hgnc_symbol'] = ref_flat2['hgnc_symbol'].str.replace(r'"', '', regex=True)
    ref_flat2['HGNC_ID'] = ref_flat2['HGNC_ID'].str.split('hgnc_id').str[1]
    ref_flat2['HGNC_ID'] = ref_flat2['HGNC_ID'].str.replace(r'"', '', regex=True)
    ref_flat2['HGNC_ID'] = ref_flat2['HGNC_ID'].str.replace(r';', '', regex=True)

    #remove ws
    ref_flat2['ENSG_ID'] = ref_flat2['ENSG_ID'].str.strip()
    ref_flat2['hgnc_symbol'] = ref_flat2['hgnc_symbol'].str.strip()
    ref_flat2['HGNC_ID'] = ref_flat2['HGNC_ID'].str.strip()
    # merge on ENSG_ID
    dat_merged = dat.merge(ref_flat2, on = 'ENSG_ID')

    # reorder columns
    dat_merged = dat_merged[['hgnc_symbol', 'HGNC_ID','ENSG_ID',
                'coverage_mean', 'coverage_std', 'coverage_CV']]

    # output string name
    output_filename = args.cov_metrics_file.replace('.tsv','.hgnc.tsv')
    # save file
    dat_merged.to_csv(
        output_filename,
        sep="\t", index=False, header=True
        )


if __name__ == "__main__":

    main()