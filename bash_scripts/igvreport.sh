#!/bin/bash
#for f in *.sam
for f in $1/*_R1_001.fastq.gz
do
        f1=${f##*/}
      
        #name="4059_5259"
        #fixmate and compress bam
        ref_num=${f1##*pAI-}   # Remove the left part.
        ref_num=${ref_num:0:4}  # Remove the right part.
        ref="pAI-$ref_num"
        
         name=${f1%%\_L001*}
         catch="$PWD/$2/igvreport/$name.html"
        if [[ ! -e "$catch" ]]
          then
        
create_report $PWD/Asimov_fasta/$ref.fasta.bed  $PWD/Asimov_fasta/$ref.fasta --flanking 500   --tracks $PWD/$2/mapping/$name.sorted.dedup.bam  --output $PWD/$2/igvreport/$name.html
    fi
done




