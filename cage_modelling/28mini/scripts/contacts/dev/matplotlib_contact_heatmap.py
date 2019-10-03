#!/usr/bin/env python
#

#https://riptutorial.com/matplotlib/example/17254/heatmap

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--i", help="Input file for plotting")
args = parser.parse_args()

##Get actual contacts from chimera output
#Read contacts in csv format
df = pd.read_csv(args.i, header=0)

# Generate numpy array from pandas DataFrame
npres1 = df['res1'].values
npres2 = df['res2'].values

##Do the plotting using matplotlib
# Define bins per axis.
N_bins = 100

# Construct 2D histogram from data using the 'plasma' colormap
plt.hist2d(npres1, npres2, bins=N_bins, normed=False, cmap=plt.cm.BuPu)

# Plot a colorbar with label.
cb = plt.colorbar()
cb.set_label('Number of entries')

# Add title and labels to plot.
plt.title('Heatmap of 2D normally distributed data points')
plt.xlabel('x axis')
plt.ylabel('y axis')

# Show the plot.
plt.show()
