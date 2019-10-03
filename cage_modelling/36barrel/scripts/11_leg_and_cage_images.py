#!/usr/bin/env python
#

# This script assumes you are in the working directory of the files to process
#
# ./map 	should contain the map to fit to and that matrices align the structure to
# ./PDB		should contain the reference structure/model to use to build the TS
#
# Launch script by:
# $ chimera build_28mini.py

#####################################################################################
# User variable
#####################################################################################

#directory="PDB_built_geometry/P-PH-PP-H"
directory="PDB_built_final"

#Define residue ranges for angle measurements
txdN = '1594'
txdC = '1630'
proxN = '1282'
proxC = '1550'
distjN = '1135'
distjC = '1230'
distN = '870'
distC = '1090'
ankleN = '635'
ankleC = '815'

# Required variables
threshold = 6               # Volume threshold, in sigma
origin = 'originIndex 0'    # Insert an volume origin command here if desired

#####################################################################################
# Python module import, chimera command and variable setup
#####################################################################################

# Python modules to load
import chimera
import os			    # For running OS commands
import subprocess 		# For invoking bash scripts inside this python script
import fnmatch          # For gettin numbers of files
import shutil           # For deleting existing analysis folders
from shutil import copyfile

from chimera import runCommand as rc # use 'rc' as shorthand for rc
from chimera import replyobj # for emitting status messages
from chimera.tkgui import saveReplyLog, clearReplyLog

# Current working directory is set
dir = os.getcwd()
print 'Current working diretory set:'
print dir

# Gather name of map found in the /map folder
os.chdir("map")
for file in os.listdir("."):
    if file.endswith(".mrc"):
        map=file
os.chdir("..")

# Gather the number of and names of PDB files in the defined PDB folder, note use of sorted
os.chdir(directory)
pdblist = [fn for fn in sorted(os.listdir(".")) if fn.endswith(".pdb")]
# No of PDB's to sub-volume average the fitted density of
pdbno = len(fnmatch.filter(os.listdir('.'), '*.pdb'))
os.chdir(dir)

shutil.rmtree(str(dir)+'/'+str(directory)+'_angles', ignore_errors=True)
os.mkdir(str(dir)+'/'+str(directory)+'_angles')

#####################################################################################
# Do the stuff
#####################################################################################

##Create image aligned heavy chains with principle component axes highlighted
#Setup views
rc('open '+str(dir)+'/scripts/ref_PDB.pdb')
rc('reset; turn y -90; focus; turn x 60; focus; turn z -35; focus; turn y 30')
rc('savepos ref')

#Open structures
for i in range(0,pdbno):
  #Store current PDB name wihtout extension
  file=str(pdblist[i])
  name=os.path.splitext(file)[0]
  #Opens structures
  rc('open '+str(dir)+"/"+str(directory)+"/"+str(file))

#Color
# Fix secondary structure
rc('ksdssp #')
## Color by sequence/domain
rc('color_CHC #')

#Align structures
for i in range(0,pdbno):
    rc('match #'+str(i+1)+':1500-1600 #0:1500-1600')

rc('savepos aligned')

#Define principal component axes
for i in range(0,pdbno):
  file=str(pdblist[i])
  rc('define axis radius 5 name txd raiseTool False #'+str(i+1)+':'+str(txdN)+'-'+str(txdC))
  rc('define axis radius 5 name prox raiseTool False #'+str(i+1)+':'+str(proxN)+'-'+str(proxC))
  rc('define axis radius 5 name distj raiseTool False #'+str(i+1)+':'+str(distjN)+'-'+str(distjC))
  rc('define axis radius 5 name dist raiseTool False #'+str(i+1)+':'+str(distN)+'-'+str(distC))
  rc('define axis radius 5 name ankle raiseTool False #'+str(i+1)+':'+str(ankleN)+'-'+str(ankleC))

#Save session
rc('~modeldisplay #0; focus')
rc('save '+str(dir)+"/chimera/2_build_final_measure_angles_session_legs.py")
rc('fancy; ~shadows; focus')
rc('copy file '+str(dir)+'/chimera/2_build_final_measure_angles_session_legs.png png supersample 4')

#Make an image of the whole cage
rc('close #0')
# Open map back into #0
rc('open #0 '+str(dir)+'/map/'+str(map))
rc('volume #0 transparency 0.7 voxelSize 1.705 '+str(origin))
# Get PDB's into map
rc('reset')
# Remove pax axes
rc('~define')

#Save session
rc('save '+str(dir)+"/chimera/2_build_final_measure_angles_session_cage.py")
rc('copy file '+str(dir)+'/chimera/2_build_final_measure_angles_session_cage.png png supersample 4')
