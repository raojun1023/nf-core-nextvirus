process CDHIT {
    label "viroprofiler_base"
    conda '/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/miniconda3/envs/cd-hit'


    input:
    file(contigslib)
    val(assembler)

    output:
    path("${assembler}_vOTUs_consensus.fasta"), emit: nrviruslib  // 正确语法
    path("${assembler}_min_comp.tsv"), emit: nrvirustsv           // 正确语法

    script:
    """
    # append all the mined viral scaffolds
    cat ${contigslib} > concat_${assembler}.fasta
    # set viral scaffolds reads header to be unique
    seqkit rename concat_${assembler}.fasta > concat_unique_${assembler}.fasta
    # CD-HIT-EST
    cd-hit-est \
    -T 80 \
    -M 80G \
    -i concat_unique_${assembler}.fasta \
    -o derep95_${assembler}.fasta \
    -c 0.95 \
    -aS 0.85 \
    -n 9 \
    -d 0 \
    -p 1 \
    -t 4 \
    -g 1
    # filter dereplicated sequences by length
    seqkit seq \
    --min-len 3000 \
    --out-file filtered_derep95_${assembler}.fasta \
    derep95_${assembler}.fasta
    # obtain which mined viral scaffold collapse in a vOTU
    miner_comparison.py ${assembler}
    # sort vOTU file by name
    seqkit sort --id-regexp ">vOTU_([0-9]+)" vOTU_${assembler}.fasta > ${assembler}_vOTUs_consensus.fasta
    """
}
