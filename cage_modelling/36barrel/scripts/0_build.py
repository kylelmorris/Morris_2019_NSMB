#!/usr/bin/env python
#

# This script assumes you are in the working directory of the files to process
#
# ./map 	should contain the map to fit to and that matrices align the structure to
# ./PDB		should contain the reference structure/model to use to build the TS
#
# Launch script by:
# $ chimera build_*.py

#####################################################################################
# REQUIRED VARIABLES - edit these to make point the script to PDB's
#####################################################################################

# Required variables
threshold = 3               # Volume threshold, in sigma
origin = 'originIndex 0'    # Insert an volume origin command here if desired
#move = '-341,-341,-341'    # If the PDB's need moving, like for the tennis ball
move = '0,0,0'              # If the PDB's need moving

#####################################################################################
# Python module import, chimera command and variable setup
#####################################################################################

# Python modules to load
import chimera
import os			    # For running OS commands
import subprocess 		    # For invoking bash scripts inside this python script
import fnmatch          # For gettin numbers of files
import shutil           # For deleting existing analysis folders

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

# Gather name of PDB found in the /PDB folder
os.chdir("PDB")
for file in os.listdir("."):
    if file.endswith(".pdb"):
        model=file
os.chdir("..")

# Gather the number of and names of matrix files in the /matrix folder
#os.chdir("matrix")
#matlist = [fn for fn in os.listdir(".") if fn.endswith(".mat")]
# No of PDB's to sub-volume average the fitted density of
#matno = len(fnmatch.filter(os.listdir('.'), '*.mat'))
#os.chdir("..")

# Gather the number of and names of matrix files in the /matrix folder
os.chdir("PDB")
matlist = [fn for fn in sorted(os.listdir(".")) if fn.endswith(".pdb")]
#matlist = [fn for fn in os.listdir(".") if fn.endswith(".pdb")]
# No of PDB's to sub-volume average the fitted density of
matno = len(fnmatch.filter(os.listdir('.'), '*.pdb'))
os.chdir("..")

# Alias for backbone selection
rc('alias ^selmain sel $1:@CA,C1,N,O,C,CB')

#####################################################################################
# Open models
#####################################################################################

# Open map back into #0
rc('open #0 '+str(dir)+'/map/'+str(map))
rc('volume #0 transparency 0.7 voxelSize 1.705 '+str(origin))

#####################################################################################
# Refit PDB's into map based on number of matrices for each cage vertex
# Fitting is first round and rough, into PDB_built
#####################################################################################

shutil.rmtree(str(dir)+'/PDB_improved', ignore_errors=True)
shutil.rmtree(str(dir)+'/PDB_built', ignore_errors=True)

os.mkdir(str(dir)+'/PDB_improved')
os.mkdir(str(dir)+'/PDB_built')

for i in range(0,matno):
  ##Use existing PDB's and structural alignment to produce heavy chain triskelia model
  ##
  #Open a fresh reference model to build with
  model=str(matlist[i])
  rc('open '+str(dir)+'/PDB/'+str(model))

  #Move by translations coorindates
  rc('move '+str(move)+' models #1')

  #Improve fit to map and save matrix
  rc('fitmap #1 #0')

  #Save reference model, for reference....
  rc('write relative #0 #1 '+str(dir)+'/PDB_improved/'+str(model))

  #Reposition view
  rc('focus #1')

  #Split model and align chains, excluding terminal domains for now
  #Note the terminal HCR repeats often are poorly fitted, so align the rest of the structure and then use structure alignment to reposition the terminal HCR repeats
  rc('split #1')
  rc('mm #1.1 #1.2')
  rc('mm #1.6 #1.7')
  rc('mm #1.11 #1.12')

  #Remove overlapping residues after alignment
  rc('delete #1.1:1-1281; delete #1.2:1282-1650; delete #1.2:1-1013')
  rc('delete #1.6:1-1281; delete #1.7:1282-1650; delete #1.7:1-1013')
  rc('delete #1.11:1-1281; delete #1.12:1282-1650; delete #1.12:1-1013')
  #Close duplicate light chains
  rc('close #1.5,1.10,1.15')

  #Do local fit of chains
  #Exclude trimerisation domain and LC (#1.1,1.6,1.11 #1.4,1.9,1.14) to keep invariant
  #Excluding terminal domains for now, don't fit LC right now

  #rc('fitmap #1.1 #0')  # Fit HC 1282-1629
  rc('fitmap #1.2 #0')  # Fit HC 1014-1281
  #rc('fitmap #1.4 #0')  # Fit LC 99-226

  #rc('fitmap #1.6 #0')  # Fit HC 1282-1629
  rc('fitmap #1.7 #0')  # Fit HC 1014-1281
  #rc('fitmap #1.9 #0')  # Fit LC 99-226

  #rc('fitmap #1.11 #0')  # Fit HC 1282-1629
  rc('fitmap #1.12 #0')  # Fit HC 1014-1281
  #rc('fitmap #1.14 #0')  # Fit LC 99-226

  #Align terminal domain chains based on structure alignment
  rc('mm #1.2 #1.3')
  rc('mm #1.7 #1.8')
  rc('mm #1.12 #1.13')
  #Remove overlapping terminal residues
  rc('delete #1.3:1014-1650')
  rc('delete #1.8:1014-1650')
  rc('delete #1.13:1014-1650')

  #Local fitting of terminal domains at this stage can lead to spurious fits
  #rc('fitmap #1.3 #0')      # Fit HC 635-1013
  #rc('fitmap #1.8 #0')      # Fit HC 635-1013
  #rc('fitmap #1.13 #0')     # Fit HC 635-1013

  ##Combine chains into single model of heavy chain
  ##
  #Heavy chain 1
  rc('changechains D D #1.4')
  rc('changechains C A #1.3; changechains B A #1.2; changechains A A #1.1')
  rc('combine #1.4,1.3,1.2,1.1 modelId #2 newchainids false')
  #Heavy chain 2
  rc('changechains I I #1.9')
  rc('changechains H F #1.8; changechains G F #1.7; changechains F F #1.6')
  rc('combine #1.9,1.8,1.7,1.6 modelId #3 newchainids false')
  #Heavy chain 3
  rc('changechains N N #1.14')
  rc('changechains M K #1.13; changechains L K #1.12; changechains K K #1.11')
  rc('combine #1.14,1.13,1.12,1.11 modelId #4 newchainids false')
  #Save new models
  rc('write format pdb relative #0 #'+str(2)+' '+str(dir)+'/PDB_built/'+str(model)+'_'+str(1)+'.pdb')
  rc('write format pdb relative #0 #'+str(3)+' '+str(dir)+'/PDB_built/'+str(model)+'_'+str(2)+'.pdb')
  rc('write format pdb relative #0 #'+str(4)+' '+str(dir)+'/PDB_built/'+str(model)+'_'+str(3)+'.pdb')

  #Select backbone of models for c-alpha and save
  #rc('selmain #2; write selected format pdb relative #0 #'+str(2)+' '+str(dir)+'/PDB_built_calpha/'+str(model)+'_'+str(1)+'_ca.pdb')
  #rc('selmain #3; write selected format pdb relative #0 #'+str(3)+' '+str(dir)+'/PDB_built_calpha/'+str(model)+'_'+str(2)+'_ca.pdb')
  #rc('selmain #4; write selected format pdb relative #0 #'+str(4)+' '+str(dir)+'/PDB_built_calpha/'+str(model)+'_'+str(3)+'_ca.pdb')

  #Make a 3IYV terminal domain alignment for making a full hypothetical model
  #rc('open #1000 '+str(dir)+'/scripts/ref/3IYV_main_chain_A.pdb')
  #rc('open #1001 '+str(dir)+'/scripts/ref/3IYV_main_chain_A.pdb')
  #rc('open #1002 '+str(dir)+'/scripts/ref/3IYV_main_chain_A.pdb')
  #rc('delete #1000:705-1700')
  #rc('delete #1001:705-1700')
  #rc('delete #1002:705-1700')

  #rc('match #1000:648-704@ca #2:648-704.@ca')
  #rc('delete #1000:650-1700; delete #2:1-649')
  #rc('combine #1000,2 modelId #2 newchainsids false')

  #rc('match #1001:648-704@ca #3:648-704.@ca')
  #rc('delete #1001:650-1700; delete #3:1-649')
  #rc('combine #1001,3 modelId #3 newchainsids false')

  #rc('match #1002:648-704@ca #4:648-704.@ca')
  #rc('delete #1002:650-1700; delete #4:1-649')
  #rc('combine #1002,4 modelId #4 newchainsids false')

  #rc('write format pdb relative #0 #'+str(2)+' '+str(dir)+'/PDB_built_calpha_TD/'+str(model)+'_'+str(1)+'_ca_TD.pdb')
  #rc('write format pdb relative #0 #'+str(3)+' '+str(dir)+'/PDB_built_calpha_TD/'+str(model)+'_'+str(2)+'_ca_TD.pdb')
  #rc('write format pdb relative #0 #'+str(4)+' '+str(dir)+'/PDB_built_calpha_TD/'+str(model)+'_'+str(3)+'_ca_TD.pdb')

  #Clean up for next round
  rc('close #1-4')

#####################################################################################
# Load back all structures
#####################################################################################

# Gather the number of and names of matrix files in the /matrix folder
os.chdir("PDB_built")
pdblist = [fn for fn in sorted(os.listdir(".")) if fn.endswith(".pdb")]
# No of PDB's to sub-volume average the fitted density of
pdbno = len(fnmatch.filter(os.listdir('.'), '*.pdb'))
os.chdir("..")

#Open structures
for i in range(0,pdbno):
  file=str(pdblist[i])
  rc('open '+str(dir)+'/PDB_built/'+str(file))

# Fix secondary structure
rc('ksdssp #')
## Color by sequence/domain
rc('alias ^color_chc color #F49AEB $1:1-330; color #fb9a99 $1:331-838; color #6a3d9a $1:839-1074; color #6a3d9a $1:1075-1198; color #1F78B4 $1:1199-1576; color #da0048 $1:1577-1675; color #ADD8E6 $1:.D:.I:.N:.O:.E:.J')
rc('color_chc #')

#Save session
shutil.rmtree(str(dir)+'/chimera', ignore_errors=True)
os.mkdir(str(dir)+'/chimera')
rc('save '+str(dir)+'/chimera/0_build_chimera_session.py')

#Stop
rc('stop')
