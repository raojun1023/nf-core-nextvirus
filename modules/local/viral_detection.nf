process CHECKV {
    label "viroprofiler_base"
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/checkv'

    input:
    path contigs

    output:
    // TODO nf-core: Named file extensions MUST be emitted for ALL output channels
    path "quality_summary.tsv", emit: checkv2vContigs_ch
    path "checkv_qc_long.fasta", emit: checkv_qc_ch
    path "quality_summary_proviruses.tsv"
    path "*.list"
    // TODO nf-core: List additional required output channels/values here
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    """
    run_checkv.sh $contigs $params.contig_minlen \$(pwd) $task.cpus $params.assembler ${params.db}/checkvdb/checkv-db-v1.0
    mv viruses.fna checkv_qc.fasta
    while [ -s proviruses_nextInput.fna ] ; do
        dir_new=run_\$(date +"%Y%m%d%h%s")
        run_checkv.sh proviruses_nextInput.fna $params.contig_minlen \$dir_new 1 $params.assembler ${params.db}/checkvdb/checkv-db-v1.0
        cat \$dir_new/viruses.fna >> checkv_qc.fasta
        csvtk concat -t quality_summary_viruses.tsv \$dir_new/quality_summary_viruses.tsv > quality_summary.tsv
        cp quality_summary.tsv quality_summary_viruses.tsv
        sed 1d \$dir_new/quality_summary_proviruses.tsv >> quality_summary_proviruses.tsv
        cat \$dir_new/proviruses_short.fna >> proviruses_short.fna
        cat \$dir_new/proviruse_ids_raw.list >> proviruse_ids_raw.list
        cat \$dir_new/proviruse_ids_clean.list >> proviruse_ids_clean.list
        cp \$dir_new/proviruses_nextInput.fna .
        sleep 1
    done
    seqkit seq -m $params.contig_minlen checkv_qc.fasta > checkv_qc_long.fasta

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        CheckV: \$(echo \$(checkv | head -n1 | sed 's/:.*//' | sed 's/CheckV v//'))
    END_VERSIONS
    """
}


process VIRSORTER2 {
    label "viroprofiler_virsorter2"
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/viroprofiler-virsorter2'
    
    input:
    path contigs

    output:
    path "final-viral-combined-for-dramv.fa", emit: vs2_contigs_ch
    path "viral-affi-contigs-for-dramv.tab", emit: vs2_affi_ch
    path "out_vs2/final-viral-combined.fa"
    path "out_vs2/final-viral-score.tsv", emit: vs2_score_ch
    path "vs2_category.csv"
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    """
    #virsorter config --set HMMSEARCH_THREADS=$task.cpus
    virsorter run --keep-original-seq -i $contigs -w vs2-pass1 --include-groups dsDNAphage,ssDNA --min-length $params.contig_minlen --min-score 0.5 -j $task.cpus -d ${params.db}/virsorter2 all
    checkv end_to_end vs2-pass1/final-viral-combined.fa checkv -t $task.cpus -d ${params.db}/checkvdb/checkv-db-v1.0
    cat checkv/proviruses.fna checkv/viruses.fna > checkv/combined.fna
    virsorter run --seqname-suffix-off --viral-gene-enrich-off --prep-for-dramv -i checkv/combined.fna -w out_vs2 --include-groups $params.virsorter2_groups --min-length $params.contig_minlen --min-score 0.5 -j $task.cpus --provirus-off -d ${params.db}/virsorter2 all
    grep '^>' out_vs2/final-viral-combined.fa | sed 's/>//' | sed 's/||.*//' > virus_virsorter2.list
    ln -s out_vs2/for-dramv/final-viral-combined-for-dramv.fa .
    ln -s out_vs2/for-dramv/viral-affi-contigs-for-dramv.tab .
    seqkit fx2tab -n final-viral-combined-for-dramv.fa | sed 's/-cat_/,/g' | csvtk add-header -n Contig,vs2_category > vs2_category.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        VirSorter2: \$(grep 'VirSorter' .command.log | head -n1 | sed 's/.* //')
    END_VERSIONS
    """
}


process DVF {
    label "viroprofiler_binning"
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/fastqc'

    input:
    path(contigs)

    output:
    path("dvf_virus.tsv"), emit: dvf2vContigs_ch
    path("virus_dvf.list"), emit: dvflist_ch
    path("*_dvfpred.txt"), emit: dvfscore_ch
    path("dvf.fasta"), emit: dvfseq_ch
    script:
    """
    /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/viroprofiler-dvf/bin/python /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/viroprofiler-dvf/bin/dvf.py -i $contigs -o . -c $task.cpus
    dvf_output=\$(ls *_dvfpred.txt)
    /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/viroprofiler-dvf/bin/Rscript calc_qvalue.r \${dvf_output} $params.dvf_qvalue dvf_virus.tsv 
    sed 1d dvf_virus.tsv | cut -f1 > virus_dvf.list
    seqkit grep -f virus_dvf.list contigs.fasta > dvf.fasta
    """
}

process VIBRANT {
    label "viroprofiler_vibrant"
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/vibrant'
    input:
    path(contigs)

    output:
    path("VIBRANT_*"), emit: vibrant_ch
    path("VIBRANT_contigs/VIBRANT_results_contigs/VIBRANT_genome_quality_contigs.tsv"), emit: vibrant_quality_ch

    when:
    task.ext.when == null || task.ext.when

    """
    ln -s $contigs contigs.fasta
    VIBRANT_run.py -i contigs.fasta -d $params.db/vibrant/databases -m $params.db/vibrant/files -t $task.cpus -virome
    """
}


process VIRCONTIGS_PRE {
    label "viroprofiler_base"
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/viroprofiler_base'
    input:
    path(nrclib)
    path(dvflist)
    path(checkv_quality)
    path(vibrant_dir)

    output:
    path("putative_vcontigs_pref1.fasta"), emit: putative_vContigs_ch
    path("putative_vcontigs_pref1.list"), emit: putative_vList_ch

    when:
    task.ext.when == null || task.ext.when
    script:
    """
    cat ${vibrant_dir}/VIBRANT_phages_contigs/contigs.phages_combined.fna | seqkit fx2tab -n > vibrant_vcontigs.list
    csvtk grep -t -r -f checkv_quality -p 'Complete|High-quality|Medium-quality|Low-quality' $checkv_quality | cut -f1 | sed 1d > checkv_vcontigs.list
    cat $dvflist checkv_vcontigs.list vibrant_vcontigs.list | sort -u > putative_vcontigs_pref1.list
    seqkit grep -f putative_vcontigs_pref1.list $nrclib > putative_vcontigs_pref1.fasta
    """
}
