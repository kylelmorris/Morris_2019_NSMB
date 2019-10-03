#!/bin/bash
#

filein=$1

# Get input dir, path and ext and report
dir=$(dirname $filein)
name=${filein%.*}
ext=${filein#$name.}

#Extract residues
awk 'NR>8' ${filein} | awk '$1 != $5 {print}' | awk '$10 > 0' | awk {'print $3'} | cut -d "." -f 1 > res1.dat
awk 'NR>8' ${filein} | awk '$1 != $5 {print}' | awk '$10 > 0' | awk {'print $7'} | cut -d "." -f 1 > res2.dat

# Create csv from .dat residue lists
paste res1.dat res2.dat > res1-2.dat
echo res1,res2,no > contacts.csv
awk {'print $1,$2,"1"'} res1-2.dat | awk '$1 != $2' | sed 's/ /,/g' >> contacts.csv
sed 's/,/ /g' contacts.csv > contacts.txt

# Tidy up
rm -rf res1.dat res2.dat res1-2.dat
rm -rf contacts.txt
mv contacts.csv ${dir}/${name}.csv
#mv contacts.txt ${dir}/${name}.txt
