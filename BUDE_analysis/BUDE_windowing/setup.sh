#!bin/bash

# Get the PDB file in BUDE-friendly formats:

if [ $# -ne 1 ]; then
    echo " "
    echo "The script must have one argument, namely a pdb file"
    echo $0: "Usage: bash setup.sh my_pdb_file" 
    echo " "
    exit 1
fi

pdbfile=$1

if [ -e hub.pdb ] 
then
   rm hub.pdb 
fi

cp ${pdbfile} hub.pdb
babel -i pdb hub.pdb -o mol2 hub.mol2
bude_padPDB -i hub.pdb
babel -i pdb hub_padded_80.pdb -o mol2 hub_padded_80.mol2

# also make the generic link to the mol2 format file:
cd inter
ln -sf ../hub_padded_80.mol2 mol2-format
cd ../
