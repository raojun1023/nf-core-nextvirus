process TAXONOMY_VCONTACT {
        label "viroprofiler_taxa"
        conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/viroprofiler-taxa'

    input:
        path contigs

    output:
        path "out_vContact2/genome_by_genome_overview.csv", emit: taxa_vc_ch
        path "out_vContact2/c1.ntw"
        path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
        """
    seqkit seq -m ${params.contig_minlen_vcontact2} ${contigs} > input.fasta
    prodigal-gv -i input.fasta -o all.gff -a all.faa -d all.fna -p meta -f gff
    mkdir -p prodigal
    mv all.faa all.fna prodigal
    seqkit seq -m 1 prodigal/all.faa | sed 's/*//' |  grep -v '^\$' > proteins.faa
    seqkit seq -m 1 prodigal/all.fna | sed 's/*//' |  grep -v '^\$' > genes.fna
    gene_to_genome.py -a proteins.faa -o vcontact_gene2genome.tsv
    vcontact2 --raw-proteins proteins.faa --rel-mode 'Diamond' --proteins-fp vcontact_gene2genome.tsv --db 'ProkaryoticViralRefSeq211-Merged' --pcs-mode MCL --vcs-mode ClusterONE --output-dir out_vContact2 -t ${task.cpus} --pc-inflation ${params.pc_inflation} --vc-inflation ${params.vc_inflation}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vConTACT2: \$(grep "This is vConTACT2 " .command.out | sed 's/.* //g;s/=*//g')
    END_VERSIONS
    """
}
process PHAGEGCN {
        label "viroprofiler_taxa"
        conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/phabox2'

    input:
        path contigs

    output:
        path "out_phagegcn/final_prediction/phagcn_prediction.tsv", emit: taxa_tsv
        path "out_phagegcn/final_prediction/phavip_prediction.tsv", emit: vip_tsv

    when:
    task.ext.when == null || task.ext.when

    script:
        def args = task.ext.args ?: ''
        """
    phabox2 --task phagcn ${args} --contigs ${contigs} --output-dir out_phagegcn ---threads  ${task.cpus} --dbdir /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/db/phabox/phabox_db_v2 
    """
}
