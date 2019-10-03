#!/bin/bash

# set the BUDE executable PATH here. Leave blank if BUDE was installed
# system wide
# BUDE_EXE_PATH=/home/user/bude_location/

BUDE_EXE_PATH=

let count=0
while IFS= read -r LINE; do 
  echo "$LINE" > win_range.txt
# this utility makes the appropriate coordinate sets for the BUDE "ligand"
# (the windows coordinates) and the "receptor" (the rest of the structure)
  bin/bude_scan_inter < ../hub.pdb > /dev/null
# in the bude/ sub directory we have the bude control file for a single 
# energy calculation (single_energy.inp) and this also depends on bude files in the 
# sub directory lib
  cd bude/
  ((count++))
  ${BUDE_EXE_PATH}bude -f single_energy.inp >& logs/bude.log.${count}
# now the interaction energy is extracted from a BUDE ouput file and this is written
# to the standare doutput along with the window information (in LINE)
  echo ${LINE} "   " $(grep "     1     1     1     1     1     1 " test_R01_S0001_C0000_L00001_S0001_C0000_G0001.btle | awk '{print $7}') 
  rm test_R01_S0001_C0000_L00001_S0001_C0000_G0001.btle
  cd ../
done <  all_windows.txt
