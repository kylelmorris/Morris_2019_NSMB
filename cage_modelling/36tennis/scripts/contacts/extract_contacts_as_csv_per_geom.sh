#!/bin/bash
#

module load anaconda3

#Test if cage info exists
info="map/.map_info"
if [ ! -f "$info" ]; then
    echo "Cage info in map/.map_info not found"
    echo "Exiting..."
    exit
fi

## Sorts contacts by geometry
output="PDB_built_final_geometry_contacts"

## Get cage type stored by previous scripts
cage=$(grep Map ${info} | awk '{print $2}')
if [[ -z ${cage} ]]; then
    echo "Cage info absent in ${info}"
    echo "Exiting..."
    exit
fi

csvin="scripts/geometry_classes_${cage}.csv"

## For geometry classification read from geometry_class.csv
geometry_classes=$(cat $csvin | grep $cage | awk -F"," {'print $2'} | sort -u)

## Read unique geometries present in geometry_classification file
while read -r class ; do
  echo "Making directory for geometry class contacts: ${cage}: ${class}"
  mkdir -p ${output}/${class}/PDB_contacts
  mkdir -p ${output}/${class}/PDB_images
  echo ""

  #Read structures associated with unique geometry currently worked on
  geometry_structures=$(grep $cage $csvin | grep $class | awk -F"," {'print $3'})
  echo "Moving log files and images into directory for class: ${class}"

  #Read each PDB within the unique geometry
  while read -r pdb ; do

      # Get input dir, path and ext and report
      name=${pdb%.*}
      ext=${pdb#$name.}
      #Copy contact data into geometry appropriate folder
      mv ${output}/${name}_contacts.log ${output}/${class}/PDB_contacts
      mv ${output}/${name}_contacts.png ${output}/${class}/PDB_images

  done <<< "$geometry_structures"

  echo "Done"
  echo ""

done <<< "$geometry_classes"


## Extracts the data as csv and plots for all legs in a geometry
while read -r class ; do
  #Read structures associated with unique geometry currently worked on
  echo "Working on plotting contacts for ${cage}: ${class}"
  geometry_structures=$(grep $cage $csvin | grep $class | awk -F"," {'print $3'})
  mkdir -p ${output}/${class}/all_contacts

  #First combine the files
  cat ${output}/${class}/PDB_contacts/* | grep '#' > ${output}/${class}/all_contacts/all_contacts.log
  #Call script to convert contacts to csv and plot
  cd ${output}/${class}/all_contacts
  bash ../../../scripts/contacts/contacts_to_csv.sh all_contacts.log
  python ../../../scripts/contacts/seaborn_contacts_plot.py --i all_contacts.csv --t "${cage}: ${class}"
  cd ../../..

done <<< "$geometry_classes"

## Extracts the data as csv and plots for all legs indivdually
while read -r class ; do
  #Read structures associated with unique geometry currently worked on
  geometry_structures=$(grep $cage $csvin | grep $class | awk -F"," {'print $3'})
  mkdir ${output}/${class}/all_contacts

  #Read each PDB within the unique geometry
  while read -r pdb ; do
      echo "Working on plotting contacts for ${cage}: ${class}: ${name}"
      # Get input dir, path and ext and report
      name=${pdb%.*}
      ext=${pdb#$name.}
      #Call script to convert contacts to csv and plot
      cd ${output}/${class}/PDB_contacts
      bash ../../../scripts/contacts/contacts_to_csv.sh ${name}_contacts.log
      python ../../../scripts/contacts/seaborn_contacts_plot.py --i ${name}_contacts.csv --t "${cage}: ${class}: ${name}"
      cd ../../..

  done <<< "$geometry_structures"

done <<< "$geometry_classes"
