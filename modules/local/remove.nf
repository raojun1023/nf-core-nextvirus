process REMOVE {
    tag "${meta.id}"
    label "viroprofiler_base"
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/fastqc'

    input:
    tuple val(meta), path(fastq)
    path contam_ref

    output:
    tuple val(meta), path('*.gz'), emit: reads

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    input = meta.single_end ? "in=${fastq}" : "-1 ${fastq[0]} -2  ${fastq[1]}"
    """
    bowtie2 -p 8 -x /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/db/bowtiedb/hg38.fa ${input} -S ${prefix}.sam --un-conc ${prefix}.fq ${args}
    pigz -p 8 *.fq
    rm ${prefix}.sam
    """
}
