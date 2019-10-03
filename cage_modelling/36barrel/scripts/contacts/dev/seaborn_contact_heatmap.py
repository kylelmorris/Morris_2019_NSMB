#!/usr/bin/env python
#

#A script to plot chimera residue-residue contacts as heatmap
#See https://stackoverflow.com/questions/29583312/pandas-sum-of-duplicate-attributes
#See https://www.quantinsti.com/blog/creating-heatmap-using-python-seaborn

import pandas as pd
import seaborn as sns
import matplotlib
import matplotlib.pyplot as plt
import itertools as iter
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--i", help="Input file for plotting")
args = parser.parse_args()

##Get actual contacts from chimera output
#Read contacts in csv format
df = pd.read_csv(args.i, header=0)
#Sum the repeating contacts into Total column and remove duplicates
df['Total'] = df.groupby(['res1', 'res2'])['no'].transform('sum')
dfContacts = df.drop_duplicates(subset=['res1', 'res2'])

##Prepare matrix
#Pivot dataframe into matrix for plotting
result = dfContacts.pivot(index='res1',columns='res2',values='Total')

##Write out data
fh = open("hello.txt","w")
#fh.write(dfContacts.pivot(index='res1',columns='res2',values='Total').to_csv(index=False))
fh.write(dfContacts.to_csv(index=False))
fh.close()

exit()

##Plot
## Plot with matplotlib
N_bins = 20

# Plot 2D histogram using plasma colormap
plt.hist2d(result.index, result.columns, bins=N_bins, normed=False, cmap='plasma')
plt(show)

## Plot with seaborn
#Define plot
fig, ax = plt.subplots(figsize=(9,7))
#Add title
title = "Contacts heatmap"
#Fonts etc
plt.title(title,fontsize=18)
ttl = ax.title
ttl.set_position([0.5,1.05])

#Plot heatmap in seaborn
ax = sns.heatmap(result,fmt="",linewidths=0.30,ax=ax,cmap="YlGnBu_r")

#Hide ticks
#ax.set_xticks([])
#ax.set_yticks([])
#Manipulate axes
ax.invert_yaxis()
#ax.axis('off')
#ax.set_ylim([None,1600])

#Display
plt.show()

exit()

################################################################################
#Depreceated code
################################################################################

##Create a dummy dataframe with residue 0,0 and 1600,1600 to later shape the matrix
#First make range
numbers = []
for i in range(1, 200, 1):
    numbers.append(i)
#Make number pairs - non equal
results = list(iter.permutations(numbers, 2))
dfDummy0 = pd.DataFrame(results, columns = ['res1', 'res2'])
#Make number pairs - are equal
dfDummy1 = pd.DataFrame(numbers, columns = ['res1'])
dfDummy1['res2'] = dfDummy1['res1']
#Join equal and nonequal number pairs and add 0 occupancy column
dfDummy0 = dfDummy0.append(dfDummy1)
dfDummy0['no'] = '0'
