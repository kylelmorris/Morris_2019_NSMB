#!/bin/bash
#

## Inputs
filein=$1
chainin=$2
chainout=$3

## Additional variable Setup
file=$(basename $filein .txt)

## Check inputs
if [[ -z $1 ]] || [[ -z $2 ]] || [[ -z $3 ]]; then

  echo ""
  echo "Variables empty, usage is ${0} (1) (2) (3)"
  echo ""
  echo "(1) = BUDE txt file in"
  echo "(2) = chain ID in"
  echo "(3) = chain ID out"
  echo ""

  exit

fi

echo "File in:"   $filein
echo "Chain in:"  $chainin
echo "Chain out:" $chainout
echo ""

#Create defattr_emRinger header for chimera attributes
printf "attribute: budeEnergy\nmatch mode: 1-to-1\nrecipient: residues\n" > defattr_${chainout}_${file}.txt

##Create def attribute format
#cat $filein | cat -n | awk -v chain=${chain} -v seqno=${seqno} '{print "\t:"NR-1+seqno"."chain"\t"$NF}' >> defattr_${chain}_${file}.txt
#Get sequnce ranges
cat $filein | sed 's/~/ /g' | awk '{print $4}' | sed 's/[^0-9]*//g' > seqstart.dat
cat $filein | sed 's/~/ /g' | awk '{print $5}' | sed 's/[^0-9]*//g' > seqend.dat
paste seqstart.dat seqend.dat | awk '{print $2-$1}' > seqrange.dat
range=$(head -n 1 seqrange.dat)
midpoint=$(echo ${range}"/2" | bc)
paste seqstart.dat | awk -v midpoint=$midpoint '{print $1+midpoint}' > seqaverage.dat
#Paste sequence range with BUDE score
cat seqaverage.dat | awk -v chain=${chainout} '{print "\t:"$1"."chain"\t"}' > tmp.dat
cat $filein | awk '{print $NF}' > tmp1.dat
paste -d '\0' tmp.dat tmp1.dat >> defattr_${chainout}_${file}.txt

#Tidy up
rm -rf *dat

#Report max and min
max=$(grep -v att defattr_${chainout}_${file}.txt | grep -v match | grep -v recipient| awk '{print $2}' | sort -g | tail -n 1)
min=$(grep -v att defattr_${chainout}_${file}.txt | grep -v match | grep -v recipient| awk '{print $2}' | sort -g | head -n 1)
echo ""
echo "Max is ${max}"
echo "Min is ${min}"

#Report how to run in chimera
printf "\nRun the following in chimera to load the BUDE scores as attributes:\n"
printf "\ncolor grey #\n"
printf "\nbackground solid white\n"
printf "\ndefattr $(pwd)/defattr_${chainout}_${file}.txt\n"
printf "\nrangecolor budeEnergy,a,r $min blue 0 white $max red\n"
printf "\ncolorkey 0.95,0.95 0.6,0.92 fontStyle bold fontTypeface fixed borderWidth 2 tickMarks true tickThickness 2 $min blue 0 white $max red\n"
printf "\nDone\n\n"

printf "\ndefattr $(pwd)/defattr_${chainout}_${file}.txt\n" > defattr_${chainout}_${file}.com
printf "\ncolor grey #\n" >> defattr_${chainout}_${file}.com
printf "\nbackground solid white\n" >> defattr_${chainout}_${file}.com
printf "\nrangecolor budeEnergy,a,r $min blue 0 white $max red\n" >> defattr_${chainout}_${file}.com
printf "\ncolorkey 0.95,0.95 0.6,0.92 fontStyle bold fontTypeface fixed borderWidth 2 tickMarks true tickThickness 2 $min blue 0 white $max red\n" >> defattr_${chainout}_${file}.com
