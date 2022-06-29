#!/bin/bash
for f in $PWD/$2/readcount_bam/*.tsv
do
        f1=${f##*/}
        name=${f1%%\.*}
        catch="$PWD/$2/final_metrics/$name.txt"
        if [[ ! -e "$catch" ]]
          then
       python $PWD/bash_scripts/final_metrics.py $PWD/$2/readcount_bam/$f1 > $PWD/$2/final_metrics/$name.txt
        
    fi
done



