#!/bin/bash
#

## Control Sesh's fortran scripts to measure angles

# Loop through all reply logs in ./PDB_built_final
for file in ./PDB_built_final_angles/*.axes; do

  echo "Processing: ${file}"

  name=$(basename $file .axes)

  # Tidy up reply log
  ./scripts/angles/tidy_reply_log < $file > ./PDB_built_final_angles/${name}.pax

  # Add header to segmented PDB
  cat ./PDB_built_final_angles/${name}.pax ./PDB_built_final_angles/${name}_segments.pdb > ./PDB_built_final_angles/temp.pdb
  mv ./PDB_built_final_angles/temp.pdb ./PDB_built_final_angles/${name}_segments.pdb

  # Add header to PDB
  cat ./PDB_built_final_angles/${name}.pax ./PDB_built_final_angles/${name}.pdb > ./PDB_built_final_angles/temp.pdb
  mv ./PDB_built_final_angles/temp.pdb ./PDB_built_final_angles/${name}.pdb

  # Measure the angles, produce .bild file and leg representation file
  ./scripts/angles/mk_bild_pax5 < ./PDB_built_final_angles/${name}_segments.pdb > ./PDB_built_final_angles/${name}.angles
  mv paxes.bild ./PDB_built_final_angles/${name}_pax.bild
  mv legs.bild ./PDB_built_final_angles/${name}_leg.bild
  mv legs.pdb ./PDB_built_final_angles/${name}_hinge.bild

  # Transpose Sesh format into Kyle format for subsequent analysis
  export ang1=$(cat ./PDB_built_final_angles/${name}.angles | grep ^ANGLES | awk {'print $2'})
  export ang2=$(cat ./PDB_built_final_angles/${name}.angles | grep ^ANGLES | awk {'print $3'})
  export ang3=$(cat ./PDB_built_final_angles/${name}.angles | grep ^ANGLES | awk {'print $4'})
  export ang4=$(cat ./PDB_built_final_angles/${name}.angles | grep ^ANGLES | awk {'print $5'})
  export ang5=$(cat ./PDB_built_final_angles/${name}.angles | grep ^ANGLES | awk {'print $6'})

  echo "Angle between a1 and a2 is ${ang1}" > ./PDB_built_final_angles/${name}.pdb_angles.log
  echo "Angle between a2 and a3 is ${ang2}" >> ./PDB_built_final_angles/${name}.pdb_angles.log
  echo "Angle between a3 and a4 is ${ang3}" >> ./PDB_built_final_angles/${name}.pdb_angles.log
  echo "Angle between a4 and a5 is ${ang4}" >> ./PDB_built_final_angles/${name}.pdb_angles.log
  echo "Angle between a2 and a4 is #N/A" >> ./PDB_built_final_angles/${name}.pdb_angles.log

  # Transpose NEW Sesh format into Kyle format for subsequent analysis
  # Angles
  export ang1=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_ANGLES | awk {'print $2'})
  export ang2=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_ANGLES | awk {'print $3'})
  export ang3=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_ANGLES | awk {'print $4'})
  export ang4=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_ANGLES | awk {'print $5'})
  export ang5=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_ANGLES | awk {'print $6'})

  echo "Angle between a1 and a2 is ${ang1}" > ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Angle between a2 and a3 is ${ang2}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Angle between a3 and a4 is ${ang3}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Angle between a4 and a5 is ${ang4}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Angle between a2 and a4 is #N/A" >> ./PDB_built_final_angles/${name}.pdb_torsions.log

  echo "" >> ./PDB_built_final_angles/${name}.pdb_torsions.log

  # Lengths
  export ang1=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_LENGTHS | awk {'print $2'})
  export ang2=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_LENGTHS | awk {'print $3'})
  export ang3=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_LENGTHS | awk {'print $4'})
  export ang4=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_LENGTHS | awk {'print $5'})
  export ang5=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_LENGTHS | awk {'print $6'})

  echo "Length of a1 is ${ang1}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Length of a2 is ${ang2}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Length of a3 is ${ang3}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Length of a4 is ${ang4}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Length of a5 is ${ang5}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log

  echo "" >> ./PDB_built_final_angles/${name}.pdb_torsions.log

  # Torsions
  export ang1=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_TORSIONS | awk {'print $2'})
  export ang2=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_TORSIONS | awk {'print $3'})
  export ang3=$(cat ./PDB_built_final_angles/${name}.angles | grep ^LEG_TORSIONS | awk {'print $4'})

  echo "Leg torsion 1 is ${ang1}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Leg torsion 2 is ${ang2}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log
  echo "Leg torsion 3 is ${ang3}" >> ./PDB_built_final_angles/${name}.pdb_torsions.log

  echo

done
