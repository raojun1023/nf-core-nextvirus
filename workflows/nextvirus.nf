// include some modules and subworkflows
include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { FILTER_READS } from '../subworkflows/local/filter_reads'
include { BUILD_CONTIG_LIB } from '../subworkflows/local/build_contiglib'
include { BUILD_VIRUS_LIB } from '../subworkflows/local/build_viruslib'
include { BRACKEN_DB ; BRACKEN ; BRACKEN_COMBINEBRACKENOUTPUTS } from '../modules/local/bracken'
include { CDHIT } from '../modules/local/cdhit'


workflow NEXTVIRUS {
    // Check mandatory parameters
    if (params.input) {
        ch_input = file(params.input)
    }
    else {
        exit(1, 'Input samplesheet not specified!')
    }

    //
    // SUBWORKFLOW: Read in samplesheet, validate and stage input files
    //
    INPUT_CHECK(ch_input)

    //
    // SUBWORKFLOW: Filter reads
    //
    if (params.reads_type == "clean") {
        ch_clean_reads = INPUT_CHECK.out.reads
    }
    else {
        ch_clean_reads = FILTER_READS(INPUT_CHECK.out.reads)
    }

    //
    // SUBWORKFLOW: BUILD CONTIGS LIB
    //
    BUILD_CONTIG_LIB(ch_clean_reads)
    //
    // SUBWORKFLOW: BUILD VIRUS LIB
    //
    BUILD_VIRUS_LIB(BUILD_CONTIG_LIB.out.ch_cclib)
    CDHIT(BUILD_VIRUS_LIB.out.ch_vs2contigs, "spades" )

    // Using kraken2 and bracken
    if (params.use_kraken2) {
        BRACKEN(ch_clean_reads)
        BRACKEN_COMBINEBRACKENOUTPUTS(BRACKEN.out.ch_reports.collect())
    }
}
