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
    bam=${bam_path##*/}
    bed=${bed_path##*/}
    # Run RNASeQ command depending on whether coverage is set
    docker_cmd="docker run  -v /home/dnanexus/:/data ${IMAGE_ID} /bin/bash -c \
        'cd /data ; rnaseqc ref_annot_collapse.gtf $bam --bed $bed "
    if [ "$coverage" == 'true' ]; then
        docker_cmd+=" --coverage"
    fi
    docker_cmd+=" out/rnaseqc_out'"

    eval $docker_cmd

    if [ "$coverage" == 'true' ]; then
        hgnc_file=${hgnc_path##*/}
        cd out/rnaseqc_out
        coverage_path=$(find . -type f -name "*.coverage.tsv")
        coverage_file=${coverage_path#./}
        python3 ../../hgnc_annotation.py -c $coverage_file -g $ref_annot_gtf
    fi

    echo "--------------Outputting files -----------------"

    dx-upload-all-outputs

}
