#!/bin/bash
for f in $PWD/$2/readcount_bam/*.tsv
do
        f1=${f##*/}
        name=${f1%%\.*}
        catch="$PWD/$2/parse_brc_snp/$name.txt"
        if [[ ! -e "$catch" ]]
          then
       python $PWD/bash_scripts/parse_brc_SNP.py --min-vaf 0.2 --min-base 30 --min-cov 10 $PWD/$2/readcount_bam/$f1 > $PWD/$2/parse_brc_snp/$name.txt
        
    fi
done



