#!/bin/bash
for f in $1/*_R1_001.fastq.gz
do
    f1=${f##*/}
    f2=${f1%%_R1_001.fastq.gz}"_R2_001.fastq.gz"
    
    
    ref_num=${f1##*pAI-}   # Remove the left part.
    ref_num=${ref_num:0:4}  # Remove the right part.
    ref="pAI-$ref_num.fasta"

    name=${f1%%\_L001*}
        catch="$PWD/$2/mapping/$name.sam"
        if [[ ! -e "$catch" ]]
          then
    
    bwa mem $PWD/Asimov_fasta/$ref $PWD/$2/trimmed/$f1 $PWD/$2/trimmed/$f2 > $PWD/$2/mapping/$name.sam
    fi
done



