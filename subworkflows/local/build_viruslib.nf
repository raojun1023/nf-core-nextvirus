include { CHECKV ; VIBRANT ; DVF ; VIRCONTIGS_PRE } from '../../modules/local/viral_detection'
workflow BUILD_VIRUS_LIB {
    take:
    ch_cclib 
    main:
        CHECKV(ch_cclib)
        clean_cclib_long = CHECKV.out.checkv_qc_ch
        VIBRANT(clean_cclib_long)
        DVF(clean_cclib_long)
        ch_dvfscore = DVF.out.dvfscore_ch
        ch_dvfseq = DVF.out.dvfseq_ch
        ch_dvflist = DVF.out.dvflist_ch
        VIRCONTIGS_PRE(clean_cclib_long, ch_dvflist, CHECKV.out.checkv2vContigs_ch, VIBRANT.out.vibrant_ch)
        ch_putative_vList = VIRCONTIGS_PRE.out.putative_vList_ch
        ch_putative_vContigs = VIRCONTIGS_PRE.out.putative_vContigs_ch

    emit:
    ch_putative_vContigs 

}
