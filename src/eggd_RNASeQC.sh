set -exo pipefail

main() {
    # Download all inputs in parallel
    dx-download-all-inputs

    # Load docker image
    docker load -i "${docker_name}"

    # Get image id from docker image loaded
    IMAGE_ID=$(sudo docker images --format="{{.Repository}} {{.ID}}" | grep "^ghcr" | cut -d' ' -f2)

    # Run RNASeQ command depending on whether coverage is set
    if [ "$coverage" == 'true' ]; then
        docker run  -v /home/dnanexus/:/data ${IMAGE_ID} /bin/bash -c \
        "cd /data ; rnaseqc $gtf $bam --bed $bed --coverage ." ;
    else;
        docker run  -v /home/dnanexus/:/data ${IMAGE_ID} /bin/bash -c \
        "cd /data ; rnaseqc $gtf $bam --bed $bed  ."
    fi

    echo "--------------Outputting files -----------------"
    mkdir -p /home/dnanexus/out/exon_cv/
    mkdir -p /home/dnanexus/out/exon_reads/
    mkdir -p /home/dnanexus/out/gene_fragments/
    mkdir -p /home/dnanexus/out/gene_reads/
    mkdir -p /home/dnanexus/out/gene_tpm/
    mkdir -p /home/dnanexus/out/metrics/

    mv *exon_cv.tsv /home/dnanexus/out/exon_cv/
    mv *exon_reads.gct /home/dnanexus/out/exon_reads/
    mv *gene_fragments.gct /home/dnanexus/out/gene_fragments/
    mv *gene_reads.gct /home/dnanexus/out/gene_reads/
    mv *gene_tpm.gct /home/dnanexus/out/gene_tpm/
    mv *metrics.tsv /home/dnanexus/out/metrics/

    # If coverage was selected we need to make the folder and direct the
    # the output file to it
    if [ "$coverage" == 'true' ]; then
        mkdir -p /home/dnanexus/out/coverage_tsv/
        mv *coverage.tsv /home/dnanexus/out/coverage_tsv/
    fi

    dx-upload-all-outputs

}
