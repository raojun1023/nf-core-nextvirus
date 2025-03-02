#!/bin/bash
module load CentOS/7.9/jdk/17.0.7
module load CentOS/7.9/Anaconda3/24.5.0
echo $HOME
export HOME="/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/workflow/nf-core-nextvirus"
export PATH="$PATH:/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/workflow/nf-core-nextvirus/bin"
export PATH="$PATH:/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/software/DeepVirFinder"
cd /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/workflow/nf-core-nextvirus
/cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/software/nextflow run main.nf  --input samplesheet.csv  -w /cpfs01/projects-HDD/cfff-47998b01bebd_HDD/rj_24212030018/workflow/nf-core-nextvirus/wkdir -with-conda -resume