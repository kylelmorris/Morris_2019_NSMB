#!/bin/bash
#

# Are we plotting/reading from Sesh's old or new analysis??
# old = angles
# new = torsions
type=torsions

# User variable
cage=$1

# Or take it from the map/.map_info file
cage=$(cat map/.map_info | grep Map | awk '{print $2}')

csvin="scripts/geometry_classes_${cage}.csv"
colorin="scripts/geometry_class_color.csv"

#Create a file for aggregating angle data for plotting
echo "cage,geometry,count,1,2,3,4,5,color1,color2" > leg_angles_$cage.csv
echo "cage,geometry,count,1,2,3,4,5,color1,color2" > leg_lengths_$cage.csv
echo "cage,geometry,count,1,2,3,color1,color2" > leg_torsions_$cage.csv

#Cage color definition for aggregated angle data for plotting, and map resolution
if [ $cage == '28mini' ]; then
  color1="#8DA0CB"
  legcolor="0.551 0.625 0.793"
  res='9.07'
elif [ $cage == '36barrel' ]; then
  color1="#66C2A5"
  legcolor="0.398 0.758 0.645"
  res='12.18'
elif [ $cage == '36tennis' ]; then
  color1="#E78AC3"
  legcolor="0.902 0.539 0.762"
  res='13.75'
elif [ $cage == '36fotin' ]; then
  color1="#66C2A5"
  legcolor="0.398 0.758 0.645"
  res='7.9'
elif [ $cage == 'fotin' ]; then
  color1="#66C2A5"
  legcolor="0.398 0.758 0.645"
  res='7.9'
fi

## For geometry classification read from geometry_class.csv
# This is the key code that will determine how the geometries are sorted!!!
geometry_classes=$(cat $csvin | grep $cage | awk -F"," {'print $2'} | sort -u)

#Read unique geometries present in geometry_classification file
while read -r class ; do
  echo "Making directory for geometry class: ${cage}: ${class}"
  mkdir -p PDB_built_final_geometry/${class}/PDB_angles
  mkdir -p PDB_built_final_geometry/${class}/PDB_angles_bild
  echo ""

  #Read structures associated with unique geometry currently worked on
  echo "Copying PDB's and angle measurements into directory: ${class}"
  echo "Aggregating angle data in leg_angles_$cage.csv"
  geometry_structures=$(grep $cage $csvin | grep $class | awk -F"," {'print $3'})

  i=1
  while read -r pdb ; do

    #File name
    name=$(basename $pdb .pdb)

    #Copy structure, angle log, leg and angle representation bild files
    scp -r PDB_built_final_angles/$pdb PDB_built_final_geometry/${class}
    scp -r PDB_built_final_angles/${name}_leg.bild PDB_built_final_geometry/${class}/PDB_angles_bild
    scp -r PDB_built_final_angles/${name}_pax.bild PDB_built_final_geometry/${class}/PDB_angles_bild
    scp -r PDB_built_final_angles/${pdb}_${type}.log PDB_built_final_geometry/${class}/PDB_angles

    #Edit cage color in leg bild file
    sed -i "s/green/${legcolor}/g" PDB_built_final_geometry/${class}/PDB_angles_bild/${name}_leg.bild

    #Create .bild file with only helix long axes extracted
    bash scripts/bild/extract_bild.sh PDB_built_final_geometry/${class}/PDB_angles_bild/${name}_pax.bild

    #Add to file aggregated angle data for plotting
    #Count instances of thsi geometry class
    count=$i
    #Define angles
    ang1=$(grep "Angle between a1 and a2" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $7}')
    ang2=$(grep "Angle between a2 and a3" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $7}')
    ang3=$(grep "Angle between a3 and a4" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $7}')
    ang4=$(grep "Angle between a4 and a5" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $7}')
    ang5=$(grep "Angle between a2 and a4" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $7}')
    #Color1 is already defined
    #Color2 definition is based on current geometry, strict exact match search, read from geometry_class_color.csv
    color2=$(grep -w ${class} ${colorin} | awk -F"," '{print $2}')
    #Add data to file
    echo ${cage},${class},${count},${ang1},${ang2},${ang3},${ang4},${ang5},${color1},${color2} >> leg_angles_$cage.csv

    #Define lengths
    ang1=$(grep "Length of a1 is" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $5}')
    ang2=$(grep "Length of a2 is" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $5}')
    ang3=$(grep "Length of a3 is" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $5}')
    ang4=$(grep "Length of a4 is" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $5}')
    ang5=$(grep "Length of a5 is" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $5}')
    #Color1 is already defined
    #Color2 definition is based on current geometry, strict exact match search, read from geometry_class_color.csv
    color2=$(grep -w ${class} ${colorin} | awk -F"," '{print $2}')
    #Add data to file
    echo ${cage},${class},${count},${ang1},${ang2},${ang3},${ang4},${ang5},${color1},${color2} >> leg_lengths_$cage.csv

    #Define torsions
    ang1=$(grep "Leg torsion 1 is" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $5}')
    ang2=$(grep "Leg torsion 2 is" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $5}')
    ang3=$(grep "Leg torsion 3 is" PDB_built_final_geometry/${class}/PDB_angles/${pdb}_${type}.log | awk '{print $5}')
    #Color1 is already defined
    #Color2 definition is based on current geometry, strict exact match search, read from geometry_class_color.csv
    color2=$(grep -w ${class} ${colorin} | awk -F"," '{print $2}')
    #Add data to file
    echo ${cage},${class},${count},${ang1},${ang2},${ang3},${color1},${color2} >> leg_torsions_$cage.csv

    i=$(($i+1))
  done <<< "$geometry_structures"

  echo "Done"
  echo ""

done <<< "$geometry_classes"

# Save info about the map to a file for other scripts to read in
echo "Map: ${cage}" > map/.map_info
echo "Resolution: ${res}" >> map/.map_info
echo ""
echo "Set up files created for cage type: ${cage}"
echo "Set up files created for map resolution: ${res}"
echo ""
echo "Done!"

# Setup for next script

mkdir -p PDB_built_final_geometry_plots

mv leg_angles_$cage.csv PDB_built_final_geometry_plots
mv leg_lengths_$cage.csv PDB_built_final_geometry_plots
mv leg_torsions_$cage.csv PDB_built_final_geometry_plots
