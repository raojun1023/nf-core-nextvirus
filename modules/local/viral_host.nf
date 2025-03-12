process VIRALHOST_IPHOP {
        label "viroprofiler_host"
        conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/iphop_env'

    input:
        path contigs

    output:
        path "out_iphop/Detailed_output_by_tool.csv", emit: iphop_tool_ch
        path "out_iphop/Host_prediction_to_genome_m90.csv", emit: iphop_genome_ch
        path "out_iphop/Host_prediction_to_genus_m90.csv", emit: iphop_genus_ch
        path "out_iphop/Date_and_version.log"
        path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        """
    iphop predict --fa_file ${contigs} --out_dir out_iphop --db_dir ${params.db}/iphop/Sept_2021_pub_rw --num_threads ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        iPHoP: \$(iphop --version | head -n1 | sed 's/iPHoP v//;s/: .*//')
        seqkit: \$( seqkit | sed '3!d; s/Version: //' )
    END_VERSIONS
    """
}
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
    phabox2 --task cherry ${args} --contigs ${contigs} --output-dir out_phagegcn ---threads  ${task.cpus} --dbdir /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/db/phabox/phabox_db_v2 
    """
}
