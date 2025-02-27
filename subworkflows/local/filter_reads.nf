include { FASTQC} from '../../modules/nf-core/modules/fastqc/main'
include { FASTP} from '../../modules/nf-core/modules/fastp/main'
include { TRIMMOMATIC} from '../../modules/nf-core/modules/trimmomatic/main'
include { REMOVE} from '../../modules/local/remove'

workflow FILTER_READS {
    take:
    raw_reads
    main:
    FASTQC (raw_reads)
    if (params.use_fastp) {
        FASTP (raw_reads, false, false )
        ch_clean_reads = FASTP.out.reads
    } else {
            ch_clean_reads = raw_reads
    }

    if (params.use_trimmomatic) {
        TRIMMOMATIC (raw_reads)
        ch_clean_reads = TRIMMOMATIC.out.trimmed_reads
    } else {
        ch_clean_reads = raw_reads
    }
    if (params.use_bowtie) {
            ch_bowtieref = Channel.fromPath("${params.bowtie_idx}", checkIfExists: true).first() // not useful
            REMOVE(ch_clean_reads, ch_bowtieref)
            ch_clean_reads = REMOVE.out.reads
    }

    emit:
    reads = ch_clean_reads
}