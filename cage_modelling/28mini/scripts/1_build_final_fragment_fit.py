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
# REQUIRED VARIABLES - edit these to make point the script to PDB's
#####################################################################################

# Required variables
threshold = 3               # Volume threshold, in sigma
origin = 'originIndex 0'    # Insert an volume origin command here if desired
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
print(dir)

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

# Alias for backbone selection
rc('alias ^selmain sel $1:@CA,C1,N,O,C,CB')

#####################################################################################
# Open models
#####################################################################################

# Open map back into #0
rc('open #0 '+str(dir)+'/map/'+str(map))
rc('volume #0 transparency 0.7 voxelSize 1.705 '+str(origin))

#####################################################################################
# Do next round of fitting to fit appropriate fragments ready for angle measurements
# Fitting is second round and precise fragment based, into PDB_built_final
#####################################################################################

shutil.rmtree(str(dir)+'/PDB_built_final', ignore_errors=True)
shutil.rmtree(str(dir)+'/PDB_built_final_calpha', ignore_errors=True)
shutil.rmtree(str(dir)+'/PDB_built_final_calpha_TD', ignore_errors=True)

os.mkdir(str(dir)+'/PDB_built_final')
os.mkdir(str(dir)+'/PDB_built_final_calpha')
os.mkdir(str(dir)+'/PDB_built_final_calpha_TD')

# Gather the number of and names of pdb files in the /PDB_built folder
os.chdir("PDB_built")
matlist = [fn for fn in sorted(os.listdir(".")) if fn.endswith(".pdb")]
# No of PDB's to sub-volume average the fitted density of
matno = len(fnmatch.filter(os.listdir('.'), '*.pdb'))
os.chdir("..")

for i in range(0,matno):
      #Open a TS model to build with and do fragment fitting
      model=str(matlist[i])
      rc('open '+str(dir)+'/PDB_built/'+str(model))
      #Fragment Fitting

      #Save terminal fragment 635-1013 to file for later structural alignment
      rc('select #1:635-1013')
      rc('write format pdb selected relative #0 #1 '+str(dir)+'/PDB_built_final/terminal.pdb')
      rc('delete #1:635-839')

      #Copy a terminal fragment into a new model for structural alignment later
      #rc('combine #1 modelId #2')
      #rc('delete #1:635-839')
      #rc('delete #2:1014-1630')

      #Do stepwise local alignments up until the terminal domain, exclude trimerisation domain to keep invariant
      rc('fitmap #1:840-1280 #0 moveWholeMolecules False')      # Doing initial fit with whole larger fragment get rough alignment first

      rc('fitmap #1:1131-1280 #0 moveWholeMolecules False')     # Fragment 1131-1280
      rc('fitmap #1:840-1130 #0 moveWholeMolecules False')      # Fragment 840-1130

      #Open terminal domain and do structural alignment, then local fragment fit
      rc('open #2 '+str(dir)+'/PDB_built_final/terminal.pdb')
      rc('mm #1:840-1013 #2:840-1013')

      #Do structural alignment of terminal domain, then local fragment fit
      #rc('mm #1:840-1013 #2:840-1013')

      rc('fitmap #2:635-839 #0 moveWholeMolecules False')       # Fragment 635-839
      rc('delete #2:840-1013')

      #Combine model and save
      rc('split #1')
      rc('combine #1.2,2,1.1 modelId #3 newchainids false')
      #Make sure chains are properly labelled
      rc('changechains D D #3; changechains C A #3; changechains B A #3; changechains A A #3')
      rc('changechains I I #3; changechains H F #3; changechains G F #3; changechains F F #3')
      rc('changechains N N #3; changechains M K #3; changechains L K #3; changechains K K #3')
      # Save
      rc('write relative #0 #3 '+str(dir)+'/PDB_built_final/'+str(model))

      #Select backbone of models and save
      rc('selmain #3; write selected format pdb relative #0 #3 '+str(dir)+'/PDB_built_final_calpha/'+str(model)+'_ca.pdb')

      #Make a 3IYV terminal domain alignment for making a full hypothetical model
      rc('open #1000 '+str(dir)+'/scripts/ref/3IYV_main_chain_A.pdb')
      rc('delete #1000:705-1700')

      rc('match #1000:648-704@ca #3:648-704@ca')
      rc('delete #1000:650-1700; delete #3:1-649.A; delete #3:1-649.F; delete #3:1-649.K')
      rc('split #2')
      rc('combine #1000,3 modelId #4 newchainids false')

      rc('write format pdb relative #0 #4 '+str(dir)+'/PDB_built_final_calpha_TD/'+str(model)+'_ca_TD.pdb')
      #rc('write format pdb relative #0 #'+str(3)+' '+str(dir)+'/PDB_built_final_calpha_TD/'+str(model)+'_ca_TD.pdb')

      #Clean up for next round
      rc('close #1-4; close #1000')

      #Remove terminal fragment you saved earlier
      os.remove(str(dir)+'/PDB_built_final/terminal.pdb')

#####################################################################################
# Load back all structures
#####################################################################################

# Gather the number of and names of matrix files in the /matrix folder
os.chdir("PDB_built_final")
pdblist = [fn for fn in sorted(os.listdir(".")) if fn.endswith(".pdb")]
# No of PDB's to sub-volume average the fitted density of
pdbno = len(fnmatch.filter(os.listdir('.'), '*.pdb'))
os.chdir("..")

#Open structures
for i in range(0,pdbno):
  file=str(pdblist[i])
  rc('open '+str(dir)+'/PDB_built_final/'+str(file))

# Fix secondary structure
rc('ksdssp #')
## Color by sequence/domain
rc('alias ^color_chc color #F49AEB $1:1-393; color #fb9a99 $1:394-838; color #6a3d9a $1:839-1074; color #6a3d9a $1:1075-1198; color #1F78B4 $1:1199-1576; color #da0048 $1:1577-1675; color #ADD8E6 $1:.D:.I:.N:.O:.E:.J')
rc('color_chc #')

#Save session
rc('save '+str(dir)+'/chimera/1_build_chimera_session_fragment.py')

#Stop chimera
rc('stop')

################################################################################
#Alternative fitting method NOT IN USE
################################################################################

for i in range(0,matno):
      #Open a TS model to build with and do fragment fitting
      model=str(matlist[i])
      #Open a TS model 4 times for 4 fragments
      rc('open '+str(dir)+'/PDB_built/'+str(model))
      rc('open '+str(dir)+'/PDB_built/'+str(model))
      rc('open '+str(dir)+'/PDB_built/'+str(model))
      rc('open '+str(dir)+'/PDB_built/'+str(model))

      #Fragment ranges
      frag1CT = 1629
      frag1NT = 1281
      frag2CT = 1280
      frag2NT = 1131
      frag3CT = 1130
      frag3NT = 840
      frag4CT = 839
      frag4NT = 635

      #Trim models ready for structural alignment
      rc('delete #1:1-'+frag1NT-1)                                    # Fragment 1281-1629
      rc('delete #2:1-'+frag2NT-1+'; delete #2:'+frag2CT+100+'-1629') # Fragment 1131-1280
      rc('delete #3:1-'+frag3NT-1+'; delete #3:'+frag3CT+100+'-1629') # Fragment 840-1130
      rc('delete #4:1-'+frag4NT-1+'; delete #4:'+frag4CT+100+'-1629') # Fragment 635-839

      #Fitting by structural alignment
      rc('mm #2 #1')
      rc('mm #3 #2')
      rc('mm #4 #3')

      #Fitting by local map density
      rc('fitmap #1:'+frag1NT+'-'+fra1CT+' #0 moveWholeMolecules False')     # Fragment 1281-1629
      rc('fitmap #2:'+frag2NT+'-'+fra2CT+' #0 moveWholeMolecules False')     # Fragment 1131-1280
      rc('fitmap #3:'+frag3NT+'-'+fra3CT+' #0 moveWholeMolecules False')     # Fragment 840-1130
      rc('fitmap #4:'+frag4NT+'-'+fra4CT+' #0 moveWholeMolecules False')     # Fragment 635-839

      #Trim models to final fragments
      rc('delete #1:1-'+frag1NT-1)                                  # Fragment 1281-1629
      rc('delete #2:1-'+frag2NT-1+'; delete #2:'+frag2CT+1+'-1629') # Fragment 1131-1280
      rc('delete #3:1-'+frag3NT-1+'; delete #3:'+frag3CT+1+'-1629') # Fragment 840-1130
      rc('delete #4:1-'+frag4NT-1+'; delete #4:'+frag4CT+1+'-1629') # Fragment 635-839

      #Combine fragments into one model
      rc('combine #1,2,3,4 modelId #5')

      #Save new model
      rc('write relative #0 #5 '+str(dir)+'/PDB_built_final/'+str(model))

      #Clean up for next round
      rc('close #1')
