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

#directory="PDB_built_geometry/P-PH-PP-H"
directory="PDB_built_final"

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

output='PDB_built_final_geometry_contacts'

shutil.rmtree(str(dir)+'/'+str(output), ignore_errors=True)
os.mkdir(str(dir)+'/'+str(output))

#####################################################################################
# Load back all structures
#####################################################################################

# Gather the number of and names of PDB files in the defined PDB folder, note use of sorted
os.chdir(directory)
pdblist = [fn for fn in sorted(os.listdir(".")) if fn.endswith(".pdb")]
# No of PDB's to sub-volume average the fitted density of
pdbno = len(fnmatch.filter(os.listdir('.'), '*.pdb'))
os.chdir("..")

#Open all structures
for i in range(0,pdbno):
  file=str(pdblist[i])
  rc('open '+str(dir)+'/PDB_built_final/'+str(file))

#Open reference structure for alignment
rc('open #999 '+str(dir)+'/scripts/ref_PDB.pdb')
# Save to internal view accessible by 'reset p1' for making images
rc ('~modeldisplay; modeldisplay #999')
rc('reset; focus; turn y -120; turn z -15; turn x 70; focus; savepos p1')
rc('modeldisplay #; color_CHC #; transparency 90 #')
#Close reference to prevent it finding contacts
rc('close #999')

#Save session
rc('save '+dir+'/'+str(output)+'/contacts_session.py')

# Find contacts in all legs
for i in range(0,pdbno):
    #Store current PDB name without extension
    file=str(pdblist[i])
    name=os.path.splitext(file)[0]
    #Finds contacts

    #Elaine's contact command
    #http://www.cgl.ucsf.edu/pipermail/chimera-users/2017-March/013256.html
    rc('findclash #'+str(i)+'@ca test other overlap -2.3 hbondAllowance 0.4 intraRes false intraMol False log true makePseudobonds true saveFile '+str(dir)+'/'+str(output)+'/'+str(name)+'_contacts.log')

    #Corinne's contact command
    #rc('findclash #'+str(i)+' test other overlapCutoff -1.0 hbondAllowance 0 intraRes false intraMol False log True makePseudobonds true saveFile '+str(dir)+'/'+str(output)+'/'+str(name)+'_contacts.log')

    #Make image for quality control
    rc('open #999 '+str(dir)+'/scripts/ref_PDB.pdb')
    rc('reset p1; match #'+str(i)+':1500-1600 #999:1500-1600')
    rc('matrixcopy #'+str(i)+' #0-'+str(pdbno))
    rc('transparency 0 #'+str(i))
    rc('~modeldisplay #999')
    rc('copy file '+str(dir)+'/'+str(output)+'/'+str(name)+'_contacts.png png')
    rc('reset')
    rc('transparency 90 #'+str(i))
    rc('close #999')

# Convert log files to csv for plotting, call a shell to do this
#os.chdir(str(output))
subprocess.call(str(dir)+'/scripts/contacts/extract_contacts_as_csv_per_geom.sh', shell=True)

#Stop chimera
rc('stop')
