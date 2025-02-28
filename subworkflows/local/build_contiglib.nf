include { SPADES } from '../../modules/nf-core/modules/spades/main'
include { CONTIGLIB ; CONTIGLIB_CLUSTER } from '../../modules/local/contig_library'

workflow BUILD_CONTIG_LIB {
    take:
    ch_clean_reads

    main:
        SPADES(
            ch_clean_reads.map { meta, fastq -> [meta, fastq, [], []] },
            [],
        )
            assemblies = params.assemblies == "contigs" ? SPADES.out.contigs : SPADES.out.scaffolds
            CONTIGLIB(
                assemblies.map { meta, fasta -> [fasta] }.collect()
            )
        ch_cclib = CONTIGLIB.out.cclib_long_ch

    emit:
    ch_cclib
}
