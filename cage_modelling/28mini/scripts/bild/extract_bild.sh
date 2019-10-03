#!/bin/bash
#

dir=$(dirname $1)
ext=$(echo ${file##*.})
name=$(basename $1 .${ext})

#echo "Directory: ${dir}"
#echo "Extension: ${ext}"
#echo "File name: ${name}"
#echo ""

cat $1 | grep -e blue -A 1 | grep -v -e "--" | sed 's/ 1.0/ 2.0/g' | sed 's/ 0.2 / 1.0 /g' > ${dir}/${name}_helix.${ext}

#echo "Finished extracting bild file to ${dir}/${name}_helix.${ext}"