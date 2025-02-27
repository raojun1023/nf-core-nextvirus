// include some modules and subworkflows
include { INPUT_CHECK } from '../subworkflows/local/input_check'
include { FILTER_READS } from '../subworkflows/local/filter_reads'


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
}
