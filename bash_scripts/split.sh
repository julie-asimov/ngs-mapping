#!/bin/bash
for f in fastq/*_R1_001.fastq.gz
do
    f1=${f##*/}
    f2=${f1%%_R1_001.fastq.gz}"_R2_001.fastq.gz"
    
    
    ref_num=${f1##*pAI-}   # Remove the left part.
    ref_num=${ref_num:0:4}  # Remove the right part.
    ref="pai-$ref_num.fasta"

    name=${f1%%\_L001*}
  
    bwa mem /Users/asimovinc/Documents/Asimov_fasta/$ref trimmed/$f1 trimmed/$f2 | samblaster -u split/$name.clipped.fastq | samtools view -Sb - > split/$name.clipped.bam | samtools sort - split/$name.clipped_sorted.bam
    
   
done



