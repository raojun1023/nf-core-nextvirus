process CHERRY {
        label "viroprofiler_taxa"
        conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/phabox2'

    input:
        path contigs

    output:
        path "out_phagegcn/*", emit: cherry

    when:
    task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
    phabox2 --task end_to_end  ${args} --contigs ${contigs} --output-dir out_phagegcn ---threads  ${task.cpus} --dbdir /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/db/phabox/phabox_db_v2 --skip Y
    """
}
