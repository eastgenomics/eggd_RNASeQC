set -exo pipefail

main() {

    echo "-------------- Download files and set up -----------------"
    # Download all inputs in parallel
    dx-download-all-inputs
    #Move all file paths to current directory
    find ~/in -type f -name "*" -print0 | xargs -0 -I {} mv {} ./

    # Install packages from the python asset
    pip3 install /pytz-*.whl /numpy-*.whl /pandas-*.whl

    # Install packages in the app
    export PATH=$PATH:/home/dnanexus/.local/bin  # pip installs some packages here, add to path
    sudo -H python3 -m pip install --no-index --no-deps packages/*

    # Load docker image
    docker=${docker_path##*/}
    docker load -i "${docker}"

    # Get image id from docker image loaded
    IMAGE_ID=$(sudo docker images --format="{{.Repository}} {{.ID}}" | grep "^gcr" | cut -d' ' -f2)


    echo "---------- Decompress CTAT bundle -------------"
    tar zxvf ${CTAT_bundle_path##*/}
    lib_dir=$(echo $CTAT_bundle_name |  cut -d "." -f 1,2)

    echo "------------- Collapse gtf file ----------------"
    ref_annot_gtf="/home/dnanexus/${lib_dir}/ctat_genome_lib_build_dir/ref_annot.gtf"
    python3 collapse_annotation.py $ref_annot_gtf ref_annot_collapse.gtf

    echo "-------------- Running RNASeQC -----------------"
    mkdir -p out/rnaseqc_out

    # bed file has 6 expected columns, we only need the first three
    # which is the chr, start and end
    # lets check number of columns
    bed=${bed_path##*/}
    cols=$(cat $bed | awk 'BEGIN{FS=" "};{print NF}' | sort | uniq)
    echo "number of columns in bed: " $cols
    cut -f 1,2,3 $bed > ctat_bed_formatted.bed


    # Run RNASeQ command depending on whether coverage is set
    bam=${bam_path##*/}
    docker_cmd="docker run  -v /home/dnanexus/:/data ${IMAGE_ID} /bin/bash -c \
        'cd /data ; rnaseqc ref_annot_collapse.gtf $bam --bed ctat_bed_formatted.bed "
    if [ "$coverage" == 'true' ]; then
        docker_cmd+=" --coverage"
    fi
    docker_cmd+=" out'"

    eval $docker_cmd

    if [ "$coverage" == 'true' ]; then
        cd out
        coverage_path=$(find . -type f -name "*.coverage.tsv")
        coverage_file=${coverage_path#./}
        python3 ../../../hgnc_annotation.py -c $coverage_file -g $ref_annot_gtf
    fi

    echo "--------------Outputting files -----------------"
    mkdir -p /home/dnanexus/out/exon_csv/
    mkdir -p /home/dnanexus/out/exon_reads/
    mkdir -p /home/dnanexus/out/fragmentSizes/
    mkdir -p /home/dnanexus/out/gene_fragments/
    mkdir -p /home/dnanexus/out/gene_reads/
    mkdir -p /home/dnanexus/out/gene_tpm/
    mkdir -p /home/dnanexus/out/metrics/

    cd /home/dnanexus/out/

    mv *exon_csv.tsv /home/dnanexus/out/exon_csv/
    mv *exon_reads.gct /home/dnanexus/out/exon_reads/
    mv *fragmentSizes.txt /home/dnanexus/out/fragmentSizes/
    mv *gene_fragments.gct /home/dnanexus/out/gene_fragments/
    mv *gene_reads.gct /home/dnanexus/out/gene_reads/
    mv *gene_tpm.gct /home/dnanexus/out/gene_tpm/
    mv *metrics.tsv /home/dnanexus/out/metrics/

    # If coverage metrics is made, then it needs to be outputted as well
    if [ -f *coverage.tsv ]; then
        echo "coverage.tsv exists."
        mkdir -p /home/dnanexus/out/coverage/
        mkdir -p /home/dnanexus/out/coverage_hgnc/

        mv *coverage.tsv /home/dnanexus/out/coverage/
        mv *coverage.hgnc.tsv /home/dnanexus/out/coverage_hgnc/
    else
        echo "No coverage reports generated as coverage option was not selected"
    fi

    dx-upload-all-outputs

}
