#!/bin/bash
for f in $1/*_R1_001.fastq.gz
do
   f1=${f##*/}
   f2=${f1%%_R1_001.fastq.gz}"_R2_001.fastq.gz"
   catch="$PWD/$2/ftm/$f1"
        if [[ ! -e "$catch" ]]
          then
   bbduk.sh in1=$1/$f1 in2=$1/$f2 out1=$PWD/$2/ftm/$f1 out2=$PWD/$2/ftm/$f2 ftm=5;
   fi
done



