#!/usr/bin/env python
#

#libraries
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import os
import shutil
from glob import glob

#Input data
data=glob(os.path.join("./PDB_built_final_geometry_plots", "*angles*.csv"))
#Name for output image
image='angle_plot.png'
#Cage filtering
cage=''

#Dataset read
# color1 = color by cage
# color2 = color by geometry signature consistent across all cages
df = pd.read_csv(str(data[0]), sep=',')
data = df[df['cage'].str.contains(str(cage))]

#Plot setup
fig = plt.figure()
ax = fig.add_subplot(111,projection='3d')
ax.view_init(30, 80)
#ax.view_init(90, 90)
fig.tight_layout()

###############
#plot by column
#ax.scatter(data['2'], data['3'], data['4'], c=data['color3'], s=80, marker='o', edgecolors='black', label=data['geometry'])
###############

###############
#Extract column information and convert to lists
ang2=data.loc[: , "2"]
ang2l=ang2.values.tolist()
ang3=data.loc[: , "3"]
ang3l=ang3.values.tolist()
ang4=data.loc[: , "4"]
ang4l=ang4.values.tolist()
count=data.loc[: , "count"]
countl=count.values.tolist()
#Geometry label in geoml, cage label in cagel
geom=data.loc[: , "geometry"]
geoml=geom.values.tolist()
cage=data.loc[: , "cage"]
cagel=cage.values.tolist()
#Cage color in color1, geometry color in color2
color=data.loc[: , "color2"]
colorl=color.values.tolist()
marker=data.loc[: , "color1"]
markerl=marker.values.tolist()

#plot by data in rows with loop for labelling
for i in range(len(ang2l)):
	#Plot data points, only assign a legend label if it is the first instance of that geometry signature
	#ax.scatter(ang2l[i],ang3l[i],ang4l[i],color=colorl[i], s=80, marker='o', edgecolors=markerl[i], label=cagel[i]+"_"+geoml[i] if countl[i] == 1 else "")
    ax.scatter(ang2l[i],ang3l[i],ang4l[i],color=colorl[i], s=80, marker='o', edgecolors='black', label=geoml[i] if countl[i] == 1 else "")
###############

#Add legend
#ax.legend(bbox_to_anchor=(0., 0.8, 1., .102), loc=3, ncol=5, mode="expand", borderaxespad=0.)
#ax.legend(bbox_to_anchor=(1.05, 1), loc=2, borderaxespad=0.)
#ax.legend(loc='upper left', fontsize=8, bbox_to_anchor=(0.9,1))

ax.set_xlabel('Proximal to distal angle (2)')
ax.set_ylabel('Distal to distal angle (3)')
ax.set_zlabel('Distal to ankle angle (4)')

#Get axes limits
xmax=data['2'].max()
xmin=data['2'].min()
ymax=data['3'].max()
ymin=data['3'].min()
zmax=data['4'].max()
zmin=data['4'].min()

print('data xmin-xmax: '+str(xmin)+':'+str(xmax))
print('data ymin-ymax: '+str(ymin)+':'+str(ymax))
print('data zmin-zmax: '+str(zmin)+':'+str(zmax))

#Set axes limits
#ax.set_xlim([xmin,xmax])
#ax.set_ylim([ymin,ymax])
#ax.set_zlim([zmin,zmax])

ax.set_xlim([20,47])
ax.set_ylim([12,32])
ax.set_zlim([34,48])

#save plot and move
png = os.path.isfile('./PDB_built_final_geometry_plots/angle_plot.png')
if png == True:
    os.remove("./PDB_built_final_geometry_plots/angle_plot.png")
    fig.savefig(str(image), dpi=300)
else:
    fig.savefig(str(image), dpi=300)

shutil.move("angle_plot.png", "./PDB_built_final_geometry_plots")

plt.show()
