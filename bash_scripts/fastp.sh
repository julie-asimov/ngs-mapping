#!/bin/bash
for f in $1/*_R1_001.fastq.gz
do
    f1=${f##*/}
    f2=${f1%%_R1_001.fastq.gz}"_R2_001.fastq.gz"
    catch="$PWD/$2/trimmed/$f1.fastp.json"
        if [[ ! -e "$catch" ]]
          then
    fastp --detect_adapter_for_pe --overrepresentation_analysis --correction  --cut_right --html $PWD/$2/trimmed/$f1.fastp.html --json $PWD/$2/trimmed/$f1.fastp.json --thread 2 -i $PWD/$2/ftm/$f1 -I $PWD/$2/ftm/$f2 -o $PWD/$2/trimmed/$f1 -O $PWD/$2/trimmed/$f2
       fi
done



