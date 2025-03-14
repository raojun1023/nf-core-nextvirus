process BACPHLIP {
    label "viroprofiler_replicyc"
    // TODO nf-core: List required Conda package(s).
    //               Software MUST be pinned to channel (i.e. "bioconda"), version (i.e. "1.10").
    //               For Conda, the build (i.e. "h9402c20_2") must be EXCLUDED to support installation on different operating systems.
    // TODO nf-core: See section in main README for further information regarding finding and adding container addresses to the section below.
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/viroprofiler-bacphlip'
    input:
    // TODO nf-core: Where applicable all sample-specific information e.g. "id", "single_end", "read_group"
    //               MUST be provided as an input via a Groovy Map called "meta".
    //               This information may not be required in some instances e.g. indexing reference genome files:
    //               https://github.com/nf-core/modules/blob/master/modules/bwa/index/main.nf
    // TODO nf-core: Where applicable please provide/convert compressed files as input/output
    //               e.g. "*.fastq.gz" and NOT "*.fastq", "*.bam" and NOT "*.sam" etc.
    path contigs

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    path "*.bacphlip", emit: bacphlip_ch
    path "*.hmmsearch.tsv"
    path "versions.yml", emit: versions
    // TODO nf-core: List additional required output channels/values here
    // path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    """
    bacphlip -i $contigs $args --local_hmmsearch /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/viroprofiler-bacphlip/bin/hmmsearch

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bacphlip: 0.9.6
    END_VERSIONS
    """
}