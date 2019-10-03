#!/usr/bin/env python
#

import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)
import pandas as pd
import seaborn as sns
from matplotlib import pyplot as plt
import os

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--t", help="Title for plot")
parser.add_argument("--i", help="Input file for plotting")
args = parser.parse_args()

path = os.getcwd()
dir = os.path.basename(path)
file = args.i
name = os.path.splitext(file)[0]

df = pd.read_csv(file)

sns.set(rc={'figure.figsize':(6,6)})

sns.scatterplot(x='res1', y='res2', data=df)
plt.title(args.t)
plt.xlim([1,1700])
plt.ylim([1,1700])

#plt.show()
plt.savefig(str(path) + '/' + str(name) + '_plot_scatter.png')

sns.set(style="white", color_codes=True)
x1 = pd.Series(df["res1"], name="res1")
x2 = pd.Series(df["res2"], name="res2")
#sns.jointplot(x1, x2, kind="kde", height=7, space=0)
sns.jointplot(x1, x2, color="k", marker=".").plot_joint(sns.kdeplot, zorder=0, n_levels=6)
plt.text(20, 20, args.t)
plt.xlim([1,1700])
plt.ylim([1,1700])

#plt.show()
plt.savefig(str(path) + '/' + str(name) + '_plot_kde.png')
