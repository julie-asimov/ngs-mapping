#!/bin/bash
#for f in *.sam
for f in $PWD/$2/readcount_bam/*.tsv
do
        f1=${f##*/}
        name=${f1%%\.*}
       catch="$PWD/$2/parse_bcr/$name.txt"
        if [[ ! -e "$catch" ]]
          then
       
       python $PWD/bash_scripts/parse_brc.py $PWD/$2/readcount_bam/$f1 > $PWD/$2/parse_brc/$name.txt
        
    fi
done



