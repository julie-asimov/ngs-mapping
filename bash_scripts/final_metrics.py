#!/usr/bin/env python
import os
import argparse
import logging
import pandas as pd
import itertools
import re
from subprocess import PIPE, run

def out(command):
    result = run(command, stdout=PIPE, stderr=PIPE, universal_newlines=True, shell=True)
    return result.stdout

def find_missing(lst):
    return [x for x in range(lst[0], lst[-1]+1)
                               if x not in lst]
                               
def ranges(i):
    for a, b in itertools.groupby(enumerate(i), lambda pair: pair[1] - pair[0]):
        b = list(b)
        yield b[0][1], b[-1][1]

SCRIPT_PATH = os.path.abspath(__file__)
FORMAT = '[%(asctime)s] %(levelname)s %(message)s'
l = logging.getLogger()
lh = logging.StreamHandler()
lh.setFormatter(logging.Formatter(FORMAT))
l.addHandler(lh)
l.setLevel(logging.INFO)
debug = l.debug
info = l.info
warning = l.warning
error = l.error

DESCRIPTION = '''
Parse bam-readcount output with optional filters
'''

EPILOG = '''
'''


class CustomFormatter(argparse.ArgumentDefaultsHelpFormatter,
    argparse.RawDescriptionHelpFormatter):
  pass


parser = argparse.ArgumentParser(description=DESCRIPTION,
    epilog=EPILOG,
    formatter_class=CustomFormatter)

parser.add_argument('bam_readcount_output')
parser.add_argument('--min-cov',
    action='store',
    type=int,
    help='Minimum coverage to report variant',
    default=0)
parser.add_argument('--min-vaf',
    action='store',
    type=float,
    help='Minimum VAF to report variant',
    default=0.00)
parser.add_argument('--min-base',
    action='store',
    type=int,
    help='Minimum base quality to report variant',
    default=1)
parser.add_argument('-v',
    '--verbose',
    action='store_true',
    help='Set logging level to DEBUG')

args = parser.parse_args()

if args.verbose:
  l.setLevel(logging.DEBUG)

debug('%s begin', SCRIPT_PATH)

headers = [
             'filename','plasmid', 'SNP(s)', 'missing_position(s)', 'coverage%', 'avg_depth','mapped%'
]
print('\t'.join(headers))

##find missing segments
basename=os.path.basename(args.bam_readcount_output)
map_file=(os.path.join(os.path.dirname(os.path.dirname(args.bam_readcount_output))))
filename=(os.path.splitext(basename)[0])
map= map_file +'/mapping/'+filename+'.sorted.dedup.bam'
df=pd.read_table(args.bam_readcount_output, usecols = [0,1], header=None)
col_one_list = df.iloc[:, 1].tolist()
command_length="samtools depth -a " + str(map) +  "| awk '{c++}END{print c}'"
length=out(command_length)
if col_one_list[0] == 1 and col_one_list[-1] == int(length):
    missing_num= find_missing(col_one_list)
    ranges=ranges(missing_num)
    missing_position=str(list(ranges))[1:-1]
elif col_one_list[0] != 1 and col_one_list[-1] == int(length):
    col_one_list.insert(0,int(0))
    missing_num= find_missing(col_one_list)
    ranges=ranges(missing_num)
    missing_position=str(list(ranges))[1:-1]
elif col_one_list[0] == 1 and col_one_list[-1] != int(length):
    length=int(length)+1
    col_one_list.insert((len(col_one_list)),length)
    missing_num= find_missing(col_one_list)
    ranges=ranges(missing_num)
    missing_position=str(list(ranges))[1:-1]
elif col_one_list[0] != 1 and col_one_list[-1] != int(length):
    col_one_list.insert(0,int(0))
    length=int(length)+1
    col_one_list.insert((len(col_one_list)),length)
    missing_num= find_missing(col_one_list)
    ranges=ranges(missing_num)
    missing_position=str(list(ranges))[1:-1]

###bam QC metric
#average read depth
command_depth="samtools depth -a " + str(map) +  "| awk '{c++;s+=$3}END{print s/c}'"
avg_depth=str(out(command_depth).strip())
#% reads mapped
command_mapped="samtools flagstat " + str(map) +  "| awk -F "+'"'+"[(|%]"+ '"'+" 'NR== 5 {print $2}'"
perc_mapped=str(out(command_mapped).strip())
#breatht of coverage
command_coverage="samtools depth -a " + str(map) +  " | awk '{c++; if($3>0) total+=1}END{print (total/c)*100}'"
coverage=str(out(command_coverage).strip())

refnum = re.search('pAI-(.*)-', filename)
plasmid = "pAI-" + refnum.group(1)
mapsnp= map_file +'/parse_brc_snp/'+filename+'.txt'
listSNP= []
with open(mapsnp) as in_fh:
  rows = in_fh.readlines()[1:]
  for line in rows:
    # Strip newline from end of line
    line = line.strip()
    # Fields are tab-separated, so split into a list on \t
    fields = line.split('\t')
    # Fields in file
    filename = fields[0]  # filename
    plasmid = fields[1]  # plasmid id
    position = int(fields[2])  # Position (1-based)
    ref= fields[3].upper()  # Reference base
    base = fields[4]  # SNP/indel/del base(s)
    vaf=float(fields[5])  # frequency of snp
    depth=int(fields[6])  # depth at one base
    count=int(fields[7])  # count of SNP at one base
    num_plus_strand=int(fields[8])  # #SNP plus strand
    num_minus_strand=int(fields[9])  # #SNP minus strand
    avg_basequality=float(fields[10])  # SNP base qaulity
    listSNP.append(ref+str(position)+base)
    
info=[filename,plasmid,str(listSNP),missing_position,coverage,avg_depth,perc_mapped]
print('\t'.join(info))

debug('%s end', (SCRIPT_PATH))
