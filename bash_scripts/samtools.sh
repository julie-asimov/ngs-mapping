#!/bin/bash
#for f in *.sam
for f in $1/*_R1_001.fastq.gz
do
        f1=${f##*/}
        name=${f1%%\_L001*}
         catch="$PWD/$2/mapping/$name.sorted.dedup.bam.bai"
        if [[ ! -e "$catch" ]]
          then
        #name="4059_5259"
        #fixmate and compress bam
        samtools sort -n -O sam $PWD/$2/mapping/$name.sam | samtools fixmate -m -O bam - $PWD/$2/mapping/$name.fixmate.bam &&
        # sort
        samtools sort -O bam -o $PWD/$2/mapping/$name.sorted.bam $PWD/$2/mapping/$name.fixmate.bam &&

        # mark duplicates
        samtools markdup -r -S $PWD/$2/mapping/$name.sorted.bam $PWD/$2/mapping/$name.sorted.dedup.bam
        
        #create bai
        
        samtools index $PWD/$2/mapping/$name.sorted.dedup.bam
    fi
done



