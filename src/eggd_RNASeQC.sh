set -exo pipefail

main() {

    echo "-------------- Download files and set up -----------------"
    # Download all inputs in parallel
    dx-download-all-inputs
    #Move all file paths to current directory
    find ~/in -type f -name "*" -print0 | xargs -0 -I {} mv {} ./

    # Install packages from the python asset
    pip3 install /pytz-*.whl /numpy-*.whl /pandas-*.whl

    # Load docker image
    docker=${docker_path##*/}
    docker load -i "${docker}"

    # Get image id from docker image loaded
    IMAGE_ID=$(sudo docker images --format="{{.Repository}} {{.ID}}" | grep "^gcr" | cut -d' ' -f2)

    echo "-------------- Running RNASeQC -----------------"
    mkdir -p out/rnaseqc_out
    gtf=${gtf_path##*/}
    bam=${bam_path##*/}
    bed=${bed_path##*/}
    # Run RNASeQ command depending on whether coverage is set
    docker_cmd="docker run  -v /home/dnanexus/:/data ${IMAGE_ID} /bin/bash -c \
        'cd /data ; rnaseqc $gtf $bam --bed $bed "
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
        python3 ../../hgnc_annotation.py -c $coverage_file -hgnc ../../$hgnc_file
    fi

    echo "--------------Outputting files -----------------"

    dx-upload-all-outputs

}
