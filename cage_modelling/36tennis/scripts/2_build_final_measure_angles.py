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
# Open structures one by one for processing
#####################################################################################

#Open structures
for i in range(0,pdbno):
  #Store current PDB name wihtout extension
  file=str(pdblist[i])
  name=os.path.splitext(file)[0]

  #Make a copy of that PDB
  copyfile(str(dir)+"/"+str(directory)+"/"+str(file), str(dir)+"/"+str(directory)+"_angles/"+str(file))

  #Opens structure into #0
  rc('open '+str(dir)+"/"+str(directory)+"/"+str(file))

  #Split into fragments and trim for measuring
  rc('combine #0; combine #0; combine #0; combine #0; combine #0')
  rc('close #0')

  rc('select #1:'+str(txdN)+'-'+str(txdC)+'; select invert sel; delete selected')
  rc('select #2:'+str(proxN)+'-'+str(proxC)+'; select invert sel; delete selected')
  rc('select #3:'+str(distjN)+'-'+str(distjC)+'; select invert sel; delete selected')
  rc('select #4:'+str(distN)+'-'+str(distC)+'; select invert sel; delete selected')
  rc('select #5:'+str(ankleN)+'-'+str(ankleC)+'; select invert sel; delete selected')

  #Do combining of PDB's to get a PDB with MODEL/ENDMDL records
  rc('combine #1 modelId #0; combine #2 modelId #0; combine #3 modelId #0; combine #4 modelId #0; combine #5 modelId #0')
  rc('close #1-5')
  rc('write #0 '+str(dir)+'/'+str(directory)+'_angles/'+str(name)+'_segments.pdb')

  clearReplyLog()

  #Run inertiapdb_coc.py script to calculate principal axes for all segments
  rc('runscript '+str(dir)+'/scripts/angles/inertiapdb_coc.py')

  #Ready for next round
  rc('close #')

  #Save reply log with key principal axes definitions
  saveReplyLog(str(dir)+'/'+str(directory)+'_angles/'+str(name)+'.axes')

#Call shell script for parsing angle data
subprocess.call(str(dir)+'/scripts/angles/seshscriptrun.sh', shell=True)



rc('stop')

#####################################################################################
# Save the session and data
#####################################################################################

#Move angles folder to directory you were working in
shutil.move(str(dir)+'/PDB_angles', str(dir)+'/'+str(directory)+'/PDB_angles')

#####################################################################################
# Stop
#####################################################################################

rc('stop')

#####################################################################################
# Depreciated code
#####################################################################################

#Show principal components for image
for i in range(0,pdbno):
  file=str(pdblist[i])
  rc('define axis radius 5 name txd raiseTool False #1:'+str(i+1)+':'+str(txd))
  rc('define axis radius 5 name prox raiseTool False #1:'+str(i+1)+':'+str(prox))
  rc('define axis radius 5 name distj raiseTool False #1:'+str(i+1)+':'+str(distj))
  rc('define axis radius 5 name dist raiseTool False #1:'+str(i+1)+':'+str(dist))
  rc('define axis radius 5 name ankle raiseTool False #1:'+str(i+1)+':'+str(ankle))

rc('~ribbon')
rc('focus')
rc('ribbon; transparency 50 #')
rc('windowsize 2000 1000')
rc('set depthCue; set shadows; set bgTransparency; set silhouetteWidth 4; set silhouette; set projection orthoscopic')
rc('~set bgTransparency')

# Fix secondary structure
rc('ksdssp #')
## Color by sequence/domain
rc('color #fb9a99 #:1-330')
rc('color #fb9a99 #:331-838')
rc('color #6a3d9a #:839-1074')
rc('color #6a3d9a #:1075-1198')
rc('color #1F78B4 #:1199-1576')
rc('color #da0048 #:1577-1675')
rc('color #add8e6 #:.D:.E:.F')

#Focus in
rc('~modeldisplay #0')
rc('focus')
