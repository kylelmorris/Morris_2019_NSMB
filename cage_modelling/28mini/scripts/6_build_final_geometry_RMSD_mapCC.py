#!/usr/bin/env python
#

# Python modules to load
import chimera
import os			    # For running OS commands
import subprocess 		# For invoking bash scripts inside this python script
import glob
import fnmatch          # For gettin numbers of files
import shutil           # For deleting existing analysis folders
from shutil import copyfile

from chimera import runCommand as rc # use 'rc' as shorthand for rc
from chimera import replyobj # for emitting status messages
from chimera.tkgui import saveReplyLog, clearReplyLog

# Definition for ignoring hidden files, note use of sorted
def listdir_nohidden(path):
    return sorted(glob.glob(os.path.join(path, '*/')))

#####################################################################################
# REQUIRED VARIABLES - edit these to make point the script to PDB's
#####################################################################################

# Required variables
threshold = 3               # Volume threshold, in sigma
origin = 'originIndex 0'    # Insert an volume origin command here if desired
move = '0,0,0'              # If the PDB's need moving
#name = '28mini'             # For file naming
#res = '9.07'         # Resolution for map model cross correlation

#####################################################################################
# Get to work
#####################################################################################

# Current working directory is set
cwd = os.getcwd()
print('Current working diretory set:')
print(cwd)

# Get directories inside PDB_built_final_geometry
geom = listdir_nohidden(cwd+"/PDB_built_final_geometry")

# Get map info, name and resolution
for line in open("map/.map_info"):
 if "Map" in line:
   print(line)
   fields = line.strip().split()
   # Array indices start at 0 unlike AWK
   print(fields[1])
   name = fields[1]

for line in open("map/.map_info"):
 if "Resolution" in line:
   print(line)
   fields = line.strip().split()
   # Array indices start at 0 unlike AWK
   print(fields[1])
   res = fields[1]

# Gather name of map found in the /map folder
for file in os.listdir(cwd+"/map"):
    if file.endswith(".mrc"):
        map=file

shutil.rmtree(str(cwd)+'/PDB_built_final_geometry_all', ignore_errors=True)
os.mkdir(str(cwd)+'/PDB_built_final_geometry_all')
os.mkdir(str(cwd)+'/PDB_built_final_geometry_all/images')
os.mkdir(str(cwd)+'/PDB_built_final_geometry_all/movies_legs')
os.mkdir(str(cwd)+'/PDB_built_final_geometry_all/movies_cage')
os.mkdir(str(cwd)+'/PDB_built_final_geometry_all/PDB')

# Since we now make movies etc, set window size
rc('windowsize 1000 1000')

#####################################################################################
# Open reference model for alignment against
#####################################################################################

# Open ref PDB into #0
rc('open #0 '+str(cwd)+'/scripts/ref_PDB.pdb')

#####################################################################################
# First loop through geometry classes, then then PDB's within that geometry
#####################################################################################

# Loop through directories inside /PDB_built_final_geometry
for dir in geom:
    # Get information about geometry
    signature = os.path.basename(os.path.dirname(dir))
    print(dir)
    print (signature)

    # Gather name of PDB found in the current geometry directory
    # Note sorted is very important to make list ordered
    pdblist = [fn for fn in sorted(os.listdir(dir)) if fn.endswith(".pdb")]
    print(pdblist)
    # No of PDB's
    pdbno = len(fnmatch.filter(os.listdir(dir), '*.pdb'))

    # Create directory for RMSD, alignbment matrices and CC saveReplyLog
    shutil.rmtree(str(dir)+'/RMSD', ignore_errors=True)
    os.mkdir(str(dir)+'/RMSD')
    shutil.rmtree(str(dir)+'/mapCC', ignore_errors=True)
    os.mkdir(str(dir)+'/mapCC')
    os.mkdir(str(dir)+'/mapCC/matrix')
    os.mkdir(str(dir)+'/mapCC/images')

    # Make more appropriate view for figures, use refPDB in #0 as starting orientation
    # Save to internal view accessible by 'reset p1'
    rc ('modeldisplay #0')
    rc('reset; focus; turn y -120; turn z -15; turn x 70; focus; savepos p1')

    #Open structures
    for i in range(0,pdbno):
      file=str(pdblist[i])
      rc('open '+str(dir)+'/'+str(file))

    # Color structures because you should
    rc('color #ADD8E6 #:1-225; color #fb9a99 #:331-838; color #6a3d9a #:839-1074; color #6a3d9a #:1075-1198; color #1F78B4 #:1199-1576; color #da0048 #:1577-1675')
    rc('color white #0')
    rc('~modeldisplay #0')

    #####################################################################################
    # Measure angles
    #####################################################################################

    #
    # Currently this is implemented in 2_TS_measure_angles.py
    #

    #####################################################################################
    # Calulate RMSD of aligned models
    #####################################################################################

    # Do structural alignment
    for i in range(1,pdbno+1):
        rc('match #'+str(i)+':1500-1600@ca #0:1500-1600@ca')

    # Save matrix file for restoring structural alignmemnt
    rc('matrixget '+dir+'/RMSD/RMSD_alignment_matrix')

    # Clear reply log ready for gathering RMSD
    clearReplyLog()

    # Do RMSD measurements in a matrix
    for i in range(1,pdbno+1):
        for j in range(1,pdbno+1):
            rc('rmsd #'+str(i)+' #'+str(j))

    # Save reply log ready for calculated RMSD values
    saveReplyLog(dir+'/RMSD/RMSD.log')

    # Save session
    rc('~modeldisplay #; modeldisplay #0; focus; ~modeldisplay #; modeldisplay #1-#'+str(pdbno))
    rc('save '+dir+'/RMSD/RMSD_'+str(signature)+'_session.py')

    #####################################################################################
    # Make images of fits and set up directory with PDB's and images with geometry signature prefix
    #####################################################################################

    # Open map for cross-correlation and making images, into #999
    rc('open #999 '+str(cwd)+'/map/'+str(map))
    rc('volume #999 sdLevel 4 color grey transparency 0.8')
    #Save default cage and model orientation
    rc('savepos p2')

    # Split matrices from RMSD alignment to get map trans/rots for making images
    os.chdir(str(dir)+"RMSD")
    #Call shell script for parsing matrix files
    subprocess.call(str(cwd)+'/scripts/matrix/extract_alignment_matrices.sh', shell=True)
    # Return to working directory
    os.chdir("..")

    # Gather names of map alignment matrices
    # Note sorted is very important to make list ordered
    matlist = [fn for fn in sorted(os.listdir(dir+'/mapCC/matrix')) if fn.endswith(".mat")]
    print(matlist)
    # No of PDB's
    matno = len(fnmatch.filter(os.listdir(dir+'/mapCC/matrix'), '*.mat'))

    # Loop through matrices, apply to map keeping structure in place to inspect the alignment
    rc('2dlabels create label1 color black size 40 xpos 0.75 ypos 0.93 text ""')
    rc('2dlabels create label2 color black size 40 xpos 0.93 ypos 0.88 text ""')
    for j in range(0,matno):
        #Set view
        rc('reset p2')
        file=str(matlist[j])
        rc('matrixset '+str(dir)+'/mapCC/matrix/'+str(file))
        rc('modeldisplay #0')
        rc('turn y 60; turn x 30; focus #0; scale 0.9; clip hither 30; clip yon -80')
        rc('~modeldisplay #; modeldisplay #999; modeldisplay #'+str(j+1))
        #Make label
        rc('2dlabels delete label1; 2dlabels create label1 color black size 40 xpos 0.75 ypos 0.93 text "'+str(signature)+'"')
        rc('2dlabels delete label2; 2dlabels create label2 color black size 40 xpos 0.93 ypos 0.88 text "'+str(j+1)+'"')
        #Save image
        file=str(pdblist[j])
        rc('copy file '+str(dir)+'/mapCC/images/'+str(file)+'.png')
        rc('copy file '+str(dir)+'/../../PDB_built_final_geometry_all/images/'+str(signature)+'_'+str(file)+'.png')
        #Save image sequence for movie encoding
        rc('copy file '+str(dir)+'/../../PDB_built_final_geometry_all/movies_legs/'+str(signature)+'_image_'+str(j+1).zfill(3)+'.png')
        #Save PDB into directory with geometry signature prefix
        rc('write #'+str(j+1)+' '+str(dir)+'/../../PDB_built_final_geometry_all/PDB/'+str(signature)+'_'+str(file)+'.pdb')
        #Save this view so it can be recalled from mapCC session file, using: reset leg1, leg2, leg3 etc
        rc('savepos leg'+str(j+1))
        #Save an image of the cage with these geometries displayed
        rc('reset')
        rc('2dlabels delete label1; 2dlabels create label1 color black size 40 xpos 0.05 ypos 0.93 text "'+str(signature)+'"')
        rc('2dlabels delete label2; 2dlabels create label2 color black size 40 xpos 0.05 ypos 0.88 text "'+str(name)+'"')
        rc('~modeldisplay #; modeldisplay #1-'+str(pdbno)+'; modeldisplay #999')
        rc('copy file '+str(dir)+'/../../PDB_built_final_geometry_all/movies_cage/'+str(signature)+'_image_'+str(j+1).zfill(3)+'.png')

    rc('2dlabels delete label1; 2dlabels delete label2')

    #Call shell script encoding movie
    #subprocess.call(str(cwd)+'/scripts/matrix/extract_alignment_matrices.sh', shell=True)

    #####################################################################################
    # Calulate model-map cross correlation
    #####################################################################################

    # Reset positions to bring triskelia back onto original cage positions, save an image
    rc('reset')
    rc('~modeldisplay #; modeldisplay #1-'+str(pdbno)+'; modeldisplay #999')
    rc('copy file '+str(dir)+'/mapCC/map_CC_'+str(signature)+'.png')

    # Clear reply log ready for gathering model cross correlation
    clearReplyLog()

    # Do model-map cross correlation
    for i in range(1,pdbno+1):
        rc('molmap #'+str(i)+' '+str(res)+' modelId #1000')
        rc('measure correlation #999 #1000')
        rc('close #1000')

    # Save reply log ready for measured model cross correlation
    saveReplyLog(dir+'/mapCC/map_CC.log')

    # Save session
    rc('save '+dir+'/mapCC/map_CC_'+str(signature)+'_session.py')

    #####################################################################################
    # Close models ready for next geometry class
    #####################################################################################

    # Close structures
    rc('close #1-#'+str(pdbno))

    #####################################################################################
    # Create leg path session for figures
    #####################################################################################

    # Gather name of leg bilds found in the current geometry directory
    # Note sorted is very important to make list ordered
    leglist = [fn for fn in sorted(os.listdir(dir+'/PDB_angles_bild')) if fn.endswith("leg.bild")]
    print(leglist)
    # No of PDB's
    legno = len(fnmatch.filter(os.listdir(dir+'/PDB_angles_bild'), '*leg.bild'))

    #Open leg paths
    for i in range(0,legno):
      file=str(leglist[i])
      rc('open '+str(dir)+'PDB_angles_bild/'+str(file))

    #Apply alignment matrix
    rc('matrixset '+dir+'/RMSD/RMSD_alignment_matrix')

    # Save session
    rc('~modeldisplay #; modeldisplay #0; focus; ~modeldisplay #; modeldisplay #1-#'+str(legno))
    rc('save '+dir+'/RMSD/legs_'+str(signature)+'_session.py')

    # Close legs
    rc('close #1-#'+str(pdbno))

    #####################################################################################
    # Create principal component session for figures
    #####################################################################################

    # Gather name of leg bilds found in the current geometry directory
    # Note sorted is very important to make list ordered
    paxlist = [fn for fn in sorted(os.listdir(dir+'/PDB_angles_bild')) if fn.endswith("pax.bild")]
    print(paxlist)
    # No of PDB's
    paxno = len(fnmatch.filter(os.listdir(dir+'/PDB_angles_bild'), '*pax.bild'))

    #Open leg paths
    for i in range(0,paxno):
      file=str(paxlist[i])
      rc('open '+str(dir)+'PDB_angles_bild/'+str(file))

    #Apply alignment matrix
    rc('matrixset '+dir+'/RMSD/RMSD_alignment_matrix')

    # Save session
    rc('~modeldisplay #; modeldisplay #0; focus; ~modeldisplay #; modeldisplay #1-#'+str(paxno))
    rc('save '+dir+'/RMSD/pax_'+str(signature)+'_session.py')

    # Close pax
    rc('close #1-#'+str(paxno))

#####################################################################################
# Tidy up
#####################################################################################

#Call shell script encoding movie
os.chdir(cwd)
subprocess.call(str(cwd)+'/scripts/movie/movie_encode.sh', shell=True)

# Close chimera when finished
rc('stop')




#### Depreciated movie code

    # Loop through matrices as above but make a movie of this
    #rc('movie record')
    #rc('2dlabels create label1 color black size 40 xpos 0.75 ypos 0.93 text ""')
    #rc('2dlabels create label2 color black size 40 xpos 0.93 ypos 0.88 text ""')
    #for k in range(0,matno):
        #rc('reset p2')
        #file=str(matlist[i])
        #rc('matrixset '+str(dir)+'/mapCC/matrix/'+str(file))
        #rc('modeldisplay #0')
        #rc('turn y 60; turn x 30; focus #0; scale 0.9; clip hither 30; clip yon -80')
        #rc('~modeldisplay #; modeldisplay #999; modeldisplay #'+str(k+1))
        #rc('2dlabels delete label1; 2dlabels create label1 color black size 40 xpos 0.75 ypos 0.93 text "'+str(signature)+'"')
        #rc('2dlabels delete label2; 2dlabels create label2 color black size 40 xpos 0.93 ypos 0.88 text "'+str(k)+'"')
        #rc('wait 10')
    #rc('movie encode output '+str(dir)+'/../../PDB_built_final_geometry_all/movies/'+str(signature)+'_movie.mp4 quality highest')
    #rc('2dlabels delete label1; 2dlabels delete label2')
