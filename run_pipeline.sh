#!/bin/bash

fastq_folder=$1
parentbase=$(basename $(dirname $(dirname $(dirname "$fastq_folder"))))

mkdir -p $parentbase $parentbase/trimmed $parentbase/ftm $parentbase/mapping $parentbase/igvreport $parentbase/bamreport $parentbase/readcount_bam $parentbase/parse_brc_snp $parentbase/parse_brc $parentbase/final_metrics

bash bash_scripts/bbduk_ftm.sh $fastq_folder $parentbase &&
bash bash_scripts/fastp.sh $fastq_folder $parentbase &&
bash bash_scripts/bwa_mapping.sh $fastq_folder $parentbase &&
bash bash_scripts/samtools.sh $fastq_folder $parentbase &&
bash bash_scripts/igvreport.sh $fastq_folder $parentbase &&
bash bash_scripts/readcount.sh $fastq_folder $parentbase &&
bash bash_scripts/parse_brc.sh $fastq_folder $parentbase &&
bash bash_scripts/parse_brc_snp.sh $fastq_folder $parentbase &&
bash bash_scripts/final_metrics.sh $fastq_folder $parentbase &&
bash bash_scripts/final_summary.sh $fastq_folder $parentbase $2
