process FASTP {
    tag "${meta.id}"
    label 'process_medium'
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/fastp'

    input:
    tuple val(meta), path(reads)
    val save_trimmed_fail
    val save_merged

    output:
    tuple val(meta), path('*.fastp.fastq.gz'), optional: true, emit: reads
    tuple val(meta), path('*.json'), emit: json
    tuple val(meta), path('*.html'), emit: html
    tuple val(meta), path('*.log'), emit: log
    path "versions.yml", emit: versions
    tuple val(meta), path('*.fail.fastq.gz'), optional: true, emit: reads_fail
    tuple val(meta), path('*.merged.fastq.gz'), optional: true, emit: reads_merged

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    // Added soft-links to original fastqs for consistent naming in MultiQC
    def prefix = task.ext.prefix ?: "${meta.id}"
    // Use single ended for interleaved. Add --interleaved_in in config.
    if (meta.single_end) {
        def fail_fastq = save_trimmed_fail ? "--failed_out ${prefix}.fail.fastq.gz" : ''
        """
        [ ! -f  ${prefix}.fastq.gz ] && ln -sf ${reads} ${prefix}.fastq.gz
        cat ${prefix}.fastq.gz \\
        | fastp \\
            --stdin \\
            --stdout \\
            --in1 ${prefix}.fastq.gz \\
            --thread ${task.cpus} \\
            --json ${prefix}.fastp.json \\
            --html ${prefix}.fastp.html \\
            ${fail_fastq} \\
            ${args} \\
            2> ${prefix}.fastp.log \\
        | gzip -c > ${prefix}.fastp.fastq.gz
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
        END_VERSIONS
        """
    }
    else {
        def fail_fastq = save_trimmed_fail ? "--unpaired1 ${prefix}_1.fail.fastq.gz --unpaired2 ${prefix}_2.fail.fastq.gz" : ''
        def merge_fastq = save_merged ? "-m --merged_out ${prefix}.merged.fastq.gz" : ''
        """
        [ ! -f  ${prefix}_1.fastq.gz ] && ln -sf ${reads[0]} ${prefix}_1.fastq.gz
        [ ! -f  ${prefix}_2.fastq.gz ] && ln -sf ${reads[1]} ${prefix}_2.fastq.gz
        fastp \\
            --in1 ${prefix}_1.fastq.gz \\
            --in2 ${prefix}_2.fastq.gz \\
            --out1 ${prefix}_1.fastp.fastq.gz \\
            --out2 ${prefix}_2.fastp.fastq.gz \\
            --json ${prefix}.fastp.json \\
            --html ${prefix}.fastp.html \\
            ${fail_fastq} \\
            ${merge_fastq} \\
            --thread ${task.cpus} \\
            ${args} \\
            2> ${prefix}.fastp.log

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            fastp: \$(fastp --version 2>&1 | sed -e "s/fastp //g")
        END_VERSIONS
        """
    }
}

