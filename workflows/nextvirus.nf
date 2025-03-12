// include some modules and subworkflows
include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { FILTER_READS } from '../subworkflows/local/filter_reads'
include { BUILD_CONTIG_LIB } from '../subworkflows/local/build_contiglib'
include { BUILD_VIRUS_LIB } from '../subworkflows/local/build_viruslib'
include { ABUNDANCE_ESTIMATION } from '../subworkflows/local/abundance_estimation'

include { BRACKEN_DB ; BRACKEN ; BRACKEN_COMBINEBRACKENOUTPUTS } from '../modules/local/bracken'
include { CDHIT } from '../modules/local/cdhit'
include { TAXONOMY_VCONTACT ; TAXONOMY_MMSEQS ; TAXONOMY_MERGE } from '../modules/local/taxonomy'
include { VIRALHOST_IPHOP } from '../modules/local/viral_host'


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
    CDHIT(BUILD_VIRUS_LIB.out.ch_vs2contigs, "spades")

    // 
    // Taxonomy
    TAXONOMY_VCONTACT(CDHIT.out.nrviruslib)

    // Host detection
    VIRALHOST_IPHOP(CDHIT.out.nrviruslib)

    // Viral abundance estimation
    ABUNDANCE_ESTIMATION(ch_clean_reads, CDHIT.out.nrviruslib)

    // Using kraken2 and bracken
    if (params.use_kraken2) {
        BRACKEN(ch_clean_reads)
        BRACKEN_COMBINEBRACKENOUTPUTS(BRACKEN.out.ch_reports.collect())
    }
}
