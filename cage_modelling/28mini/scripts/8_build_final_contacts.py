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

#####################################################################################
# Do next round of fitting to fit appropriate fragments ready for angle measurements
# Fitting is second round and precise fragment based, into PDB_built_final
#####################################################################################

shutil.rmtree(str(dir)+'/PDB_built_final_contacts', ignore_errors=True)

os.mkdir(str(dir)+'/PDB_built_final_contacts')

#####################################################################################
# Load back all structures
#####################################################################################

# Gather the number of and names of matrix files in the /matrix folder
os.chdir("PDB_built_final")
pdblist = [fn for fn in os.listdir(".") if fn.endswith(".pdb")]
# No of PDB's to sub-volume average the fitted density of
pdbno = len(fnmatch.filter(os.listdir('.'), '*.pdb'))
os.chdir("..")

#Open structures
for i in range(0,pdbno):
  file=str(pdblist[i])
  rc('open '+str(dir)+'/PDB_built_final/'+str(file))

# Remove light chains
rc('delete #:.D:.E:.I:.J:.N:.O')

## Find contacts in all legs

#Elaine's contact command
#http://www.cgl.ucsf.edu/pipermail/chimera-users/2017-March/013256.html
rc('findclash #@ca test self overlap -2.3 hbondAllowance 0.4 intraRes false intraMol False log true makePseudobonds true saveFile '+str(dir)+'/PDB_built_final_contacts/all_contacts.log')

#Corinne's contact command
#rc('findclash # test self overlapCutoff -1.0 hbondAllowance 0 intraRes false intraMol False log True makePseudobonds true saveFile '+str(dir)+'/PDB_built_final_contacts/all_contacts.log')

# Convert log files to csv for plotting, call a shell to do this
#os.chdir(str(output))
subprocess.call(str(dir)+'/scripts/contacts/extract_contacts_as_csv.sh PDB_built_final_contacts/all_contacts.log', shell=True)

#Always open all maps to get the same scale
rc('open #1000 /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_28mini/6-build_TS_reviewed_contact/map/postprocess_masked.mrc')
rc('open #1001 /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_36barrel/6-build_TS_reviewed_contact/map/postprocess_masked_flipZ.mrc')
rc('open #1002 /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_36barrel/6-build_TS_reviewed_contact/map/postprocess_masked_flipZ.mrc')
rc('reset; focus; ~modeldisplay #1000-1002; color_CHC #; transparency 50 #')

#Save session
rc('focus')
rc('copy file '+str(dir)+'/PDB_built_final_contacts/all_contacts.png png')
rc('save '+str(dir)+'/PDB_built_final_contacts/all_contacts_session.py')

#Stop chimera
rc('stop')
