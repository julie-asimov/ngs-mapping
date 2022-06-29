#!/bin/bash
for f in $PWD/$2/mapping/*.sorted.dedup.bam
do
        f1=${f##*/}
        name=${f1%%\.sorted*}
        ref_num=${f1##*pAI-}   # Remove the left part.
        ref_num=${ref_num:0:4}  # Remove the right part.
        ref="pai-$ref_num.fasta"
        catch="$PWD/$2/readcount_bam/$name.tsv"
        if [[ ! -e "$catch" ]]
          then
        bam-readcount -w 0 -f $PWD/Asimov_fasta/$ref $PWD/$2/mapping/$f1 > $PWD/$2/readcount_bam/$name.tsv
        fi

done



