set -exo pipefail

main() {

    echo "-------------- Download files and set up -----------------"
    # Download all inputs in parallel
    dx-download-all-inputs
    #Move all file paths to current directory
    find ~/in -type f -name "*" -print0 | xargs -0 -I {} mv {} ./

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
    if [ "$coverage" == 'true' ]; then
        docker run  -v /home/dnanexus/:/data ${IMAGE_ID} /bin/bash -c \
        "cd /data ; rnaseqc $gtf $bam --bed $bed --coverage out/rnaseqc_out"
    else
        docker run  -v /home/dnanexus/:/data ${IMAGE_ID} /bin/bash -c \
        "cd /data ; rnaseqc $gtf $bam --bed $bed out/rnaseqc_out"
    fi

    echo "--------------Outputting files -----------------"

    dx-upload-all-outputs

}
