process SEURAT_FINDMARKER {
    tag "$fasta"
    label 'process_high'

    container "oandrefonseca/scalign:1.0"

    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        exit 1, "CELLRANGER_MKREF module does not support Conda. Please use Docker / Singularity / Podman instead."
    }

    input:
        path seurat_object

    output:
        path "${}", emit: deg_rds
        path "versions.yml", emit: versions

    when:
        task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
        cellranger \\
            mkref \\
            --genome=$reference_name \\
            --fasta=$fasta \\
            --genes=$gtf \\
            $args

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            cellranger: \$(echo \$( cellranger --version 2>&1) | sed 's/^.*[^0-9]\\([0-9]*\\.[0-9]*\\.[0-9]*\\).*\$/\\1/' )
        END_VERSIONS
        """
}
