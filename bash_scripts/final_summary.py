#!/usr/bin/env python
import glob
import pandas as pd
import argparse
import os

parser = argparse.ArgumentParser("summary file")
parser.add_argument("metric_path", help="final_metrics path")
parser.add_argument("history_path", help="historical well id csv path")
args = parser.parse_args()


dfs = []
for txt in glob.glob(args.metric_path+"/*.txt"):
  dfs.append(pd.read_table(txt))
df = pd.concat(dfs, ignore_index=True)
history = pd.read_csv(args.history_path)

df.fillna('', inplace=True)
df['SNP(s)'] =  df['SNP(s)'].apply(lambda x: x.replace('[','').replace(']',''))
df['status'] = ((df['coverage%'] == 100)).map({True:'pass', False:'fail'})
df['max'] = df.groupby('plasmid')['avg_depth'].transform('max')
# Create a mask:

# Create a mask for the basic condition
mask1 = ((df['status'] == 'pass') & (df['avg_depth'] == df['max']))

# Use loc to select rows where condition is met and input the df['col1'] value in state
df.loc[mask1, 'selected'] = 'yes'

del df['max']
df_take=df[df.selected == 'yes']
listfil=list(df_take['filename'].str.rsplit('_', 1).str.get(0))
take=[]
for x in listfil:
    new=x.replace("-","_")
    take.append(new)
history['Sample Name']=history['Sample Name'].replace('-', '_', regex=True)
df_wells = history[history['Sample Name'].isin(take)]
mp_well = list(df_wells['MP Well ID'])
gly_well =list(df_wells['Gly Well ID Plate 1'])
gly2_well= list(df_wells['Gly Well ID Plate 2'])
fulllist = (mp_well + gly_well +gly2_well)
fulllist = [fulllist for fulllist in fulllist if str(fulllist) != 'nan']
fulllist = [int(item) for item in fulllist]
output=['well' + str(s) for s in fulllist]

map_file=(((os.path.dirname(args.metric_path))))

df.to_csv((map_file+'/summary.csv'),sep=',', index=False, header=True)
with open((map_file+'/passed_wells.txt'), 'w') as f:
    f.write(','.join([str(n) for n in output]))
