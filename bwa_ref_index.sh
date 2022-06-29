#!/bin/bash
for f in Asimov_fasta/*.fasta
do
    #bwa index $f &&
    samtools faidx $f &&
    awk 'BEGIN {FS="\t"}; {print $1 FS "0" FS $2}' $f.fai > $f.bed
    
done



