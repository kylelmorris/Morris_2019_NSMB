#!/bin/bash
#

#Test if cage info exists
info="map/.map_info"
if [ ! -f "$info" ]; then
    echo "Cage info in ${info} not found"
    echo "Exiting..."
    exit
fi

## Get cage type stored by previous scripts
cage=$(grep Map ${info} | awk '{print $2}')
if [[ -z ${cage} ]]; then
    echo "Cage info absent in ${info}"
    echo "Exiting..."
    exit
fi

module load anaconda3

filein=$1

# Get input dir, path and ext and report
ext=$(echo ${filein##*.})
name=$(basename $filein .${ext})
dir=$(dirname $filein)

echo "Path:  ${dir}"
echo "Ext:   ${ext}"
echo "File:  ${name}"
echo

# For consensus hub analysis
# NR>8 			= not the header
# $10 > 0 		= is not a clash
# '$1 != $5 {print}' 	= is not a self-contact
# cut -d "." -f 1 	= Remove chain identifier
awk 'NR>8' $filein | awk '$1 != $5 {print}' | awk '$10 > 0' | awk {'print $3'} | cut -d "." -f 1 > res1.dat
awk 'NR>8' $filein | awk '$1 != $5 {print}' | awk '$10 > 0' | awk {'print $7'} | cut -d "." -f 1 > res2.dat

# For cage analysis
#awk 'NR>8' $filein | awk '$8 > 0' | awk {'print $2'} | cut -d "." -f 1 > res1.dat
#awk 'NR>8' $filein | awk '$8 > 0' | awk {'print $5'} | cut -d "." -f 1 > res2.dat

# Create csv from .dat residue lists
paste res1.dat res2.dat > res1-2.dat
echo res1,res2,no > contacts.csv
awk {'print $1,$2,"1"'} res1-2.dat | awk '$1 != $2' | sed 's/ /,/g' >> contacts.csv
sed 's/,/ /g' contacts.csv > contacts.txt

# Report number of self and non-self contacts
total=$(awk 'NR>8' $filein | wc -l)
clash=$(awk 'NR>8' $filein | awk '$10 == 0' | wc -l)
nonself=$(awk 'NR>8' $filein | awk '$1 != $5 {print}' | awk '$10 > 0' | wc -l)
self=$(awk 'NR>8' $filein | awk '$1 == $5 {print}' | awk '$10 > 0' | wc -l)

# Report useful contacts info
echo ""
echo "Total contacts:    ${total}"
echo "Self contacts:     ${self}"
echo "Non self contacts: ${nonself}"
echo "Clashes:           ${clash}"

# Tidy up
mkdir ./${dir}/${name}
mv *.dat ./${dir}/${name}
mv contacts.csv ./${dir}/${name}
mv contacts.txt ./${dir}/${name}
mv $filein ./${dir}/${name}

# Save contacts report to file
echo "" > ./${dir}/${name}/PDB_built_final_contacts_report.log
echo "Total contacts:    ${total}" >> ./${dir}/${name}/PDB_built_final_contacts_report.log
echo "Self contacts:     ${self}" >> ./${dir}/${name}/PDB_built_final_contacts_report.log
echo "Non self contacts: ${nonself}" >> ./${dir}/${name}/PDB_built_final_contacts_report.log
echo "Clashes:           ${clash}" >> ./${dir}/${name}/PDB_built_final_contacts_report.log
echo "" >> ./${dir}/${name}/PDB_built_final_contacts_report.log
echo "Note that self-contacts, clashes and light chain contacts are removed" >> ./${dir}/${name}/PDB_built_final_contacts_report.log

#Plot
cd ./${dir}/${name}
python ../../scripts/contacts/seaborn_contacts_plot.py --i contacts.csv --t "${cage}: all contacts"
cd ../..

echo ""
echo "Done!"
echo ""
