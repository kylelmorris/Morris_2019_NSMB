#!/bin/bash
#

####################################################################################
#User VARIABLES
#export LOCALREC_SCRIPTS='/Users/lfsmbe/Dropbox/Scripts/github/localrec_control/bin'
#export CHIMERA_EXE='/Applications/Science/Chimera.app/Contents/MacOS/chimera'

#export LOCALREC_SCRIPTS='/home/kmorris/Dropbox/Scripts/github/localrec_control/bin'
#export CHIMERA_EXE='/usr/bin/chimera'

#export LOCALREC_SCRIPTS=$(which localrec_create_masks.sh | sed 's/\ /\\ /g' | sed 's/(/\\(/g' | sed 's/)/\\)/g' | sed 's/\/localrec_create_masks.sh//g')
#export LOCALREC_SCRIPTS=$(which localrec_create_masks.sh | sed 's/\/localrec_create_masks.sh//g')
export LOCALREC_SCRIPTS=~/Dropbox/Scripts/github/localrec_control
export CHIMERA_EXE=$(which chimera)

####################################################################################
# Get organised
rm -rf cmm_markers
rm -rf bin

mkdir bin
echo "Script location for copying: "${LOCALREC_SCRIPTS}
scp -r ${LOCALREC_SCRIPTS}/bin/chimera_localrec_make_cmm.py bin
scp -r ${LOCALREC_SCRIPTS}/localrec_create_cmm.sh bin
scp -r ${LOCALREC_SCRIPTS}/localrec_create_subparticles.sh bin

####################################################################################

echo ''
echo 'This script is designed to cmm markers for relion localized reconstruction...'
echo 'It uses UCSF Chimera, an autorefine Relion map the same scale as your raw data and fitted PDBs'
echo ''
echo 'It assumes that your relion autorefine run_class001.mrc map is ./map'
echo 'Cmm markers will be created to create vectors to the PDBs contained in ./PDB'
echo ''
echo 'Local rec scripts:  '${LOCALREC_SCRIPTS}
echo 'Chimera executable: '${CHIMERA_EXE}
echo ''
echo 'If your directory structure and files are in place, press [Enter] key to continue...'
echo 'Note, existing cmm_marker folders will be deleted'
read p
echo ''

# Create initial masks
echo 'Using UCSF Chimera to create initial masks selected by PDBs using scolor'
echo ''

scp -r bin/chimera_localrec_make_cmm.py .
${CHIMERA_EXE} chimera_localrec_make_cmm.py ${radius}

echo ''
echo 'Done!'
echo ''
