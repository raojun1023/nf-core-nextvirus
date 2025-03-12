include { MAPPING2CONTIGS ; CONTIGINDEX ; MAPPING2CONTIGS2 ; ABUNDANCE } from '../../modules/local/abundance'
workflow ABUNDANCE_ESTIMATION {
    take:
    ch_clean_reads 

    ch_nrclib 


    main:
        CONTIGINDEX(ch_nrclib)
        MAPPING2CONTIGS2(
        ch_clean_reads,
        CONTIGINDEX.out.bowtie2idx_ch,
    )
        ch_bams = MAPPING2CONTIGS2.out.bams_ch.collect()
        ABUNDANCE(ch_bams)
}
