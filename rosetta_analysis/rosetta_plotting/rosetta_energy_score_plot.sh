#!/bin/bash
#

filein=$1
chain=$2

if [[ -z $1 ]] ; then
  echo "Usage is $(basename $0) (1) (2)"
  echo "1 - energy score file"
  echo "2 - optional chain to analyse"
  echo ""
  echo "No inputs provided..."
  echo "Please provide name of rosetta residue_energy_breakdown energy scoring output"
  echo "Exiting..."
  exit
fi

rm -rf *dat
rm -rf *txt

# File name
ext=$(echo ${filein##*.})
name=$(basename ${filein} .${ext})

# construct the other half of the Residue-Residue interaction energy matrix
# and concatenate it with the first half (this give 2 copies of the diagonal,
# but this is discarded in the windowing stuuf later, in any case)
cat ${filein} | awk '{print $1,$2,$6,$7,$8,$3,$4,$5,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,$29}' > ${name}_part2.${ext}
cat ${filein} ${name}_part2.${ext} > ${name}_full.${ext}
rm -rf ${name}_part2.${ext}

if [[ -z $2 ]] ; then
  rm -rf chain_AFK
  rm -rf chain_BGL
  rm -rf chain_CHM
  rm -rf chain_DIN
  rm -rf chain_EJO

  mkdir -p chain_AFK/pairwise
  mkdir -p chain_BGL/pairwise
  mkdir -p chain_CHM/pairwise
  mkdir -p chain_DIN/pairwise
  mkdir -p chain_EJO/pairwise

  echo chain_AFK > .dir_list
  echo chain_BGL >> .dir_list
  echo chain_CHM >> .dir_list
  echo chain_DIN >> .dir_list
  echo chain_EJO >> .dir_list

  # Split data into chains, remove onebody lines internal residue energy, split chain alpha numeric from residue number
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /A/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_AFK/energy_breakdown_Xray_A.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /B/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_BGL/energy_breakdown_Xray_B.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /C/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_CHM/energy_breakdown_Xray_C.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /D/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_DIN/energy_breakdown_Xray_D.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /E/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_EJO/energy_breakdown_Xray_E.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /F/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_AFK/energy_breakdown_Xray_F.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /G/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_BGL/energy_breakdown_Xray_G.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /H/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_CHM/energy_breakdown_Xray_H.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /I/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_DIN/energy_breakdown_Xray_I.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /J/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_EJO/energy_breakdown_Xray_J.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /K/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_AFK/energy_breakdown_Xray_K.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /L/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_BGL/energy_breakdown_Xray_L.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /M/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_CHM/energy_breakdown_Xray_M.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /N/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_DIN/energy_breakdown_Xray_N.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /O/' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_EJO/energy_breakdown_Xray_O.dat

  # Get pairwise residue information
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /A/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_AFK/pairwise/energy_breakdown_Xray_A_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /B/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_BGL/pairwise/energy_breakdown_Xray_B_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /C/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_CHM/pairwise/energy_breakdown_Xray_C_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /D/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_DIN/pairwise/energy_breakdown_Xray_D_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /E/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_EJO/pairwise/energy_breakdown_Xray_E_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /F/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_AFK/pairwise/energy_breakdown_Xray_F_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /G/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_BGL/pairwise/energy_breakdown_Xray_G_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /H/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_CHM/pairwise/energy_breakdown_Xray_H_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /I/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_DIN/pairwise/energy_breakdown_Xray_I_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /J/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_EJO/pairwise/energy_breakdown_Xray_J_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /K/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_AFK/pairwise/energy_breakdown_Xray_K_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /L/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_BGL/pairwise/energy_breakdown_Xray_L_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /M/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_CHM/pairwise/energy_breakdown_Xray_M_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /N/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_DIN/pairwise/energy_breakdown_Xray_N_pairwise.dat
  cat ${name}_full.${ext} | grep -v onebody | awk '$4 ~ /O/' | awk {'print $4,$5,$7,$8,$28'}  | \
  sed -r 's/([0-9])([a-zA-Z])/\1 \2/g; s/([a-zA-Z])([0-9])/\1 \2/g' > chain_EJO/pairwise/energy_breakdown_Xray_O_pairwise.dat

  # Remove intramolecular contacts in pairwise files
  for f in chain*/pairwise/*.dat ; do
    # Write intermolecular contacts to file
    cat ${f} | awk ' $2 != $5 ' > tmp.dat
    mv tmp.dat ${f}
  done

  #Plotting script setup
  path=$(dirname $0)
  cp -r ${path}/plot/plot_AFK.gpt chain_AFK
  cp -r ${path}/plot/plot_BGL.gpt chain_BGL
  cp -r ${path}/plot/plot_CHM.gpt chain_CHM
  cp -r ${path}/plot/plot_DIn.gpt chain_DIN
  cp -r ${path}/plot/plot_EJo.gpt chain_EJO

else

  rm -rf chain_${chain}
  mkdir chain_${chain}
  echo chain_${chain} > .dir_list

  # Extract specific chain you need to analyse
  cat ${name}_full.${ext} | grep -v onebody | awk -v chain=$chain '$4 ~ chain' | awk {'print $4,$7,$28'} | sed 's/[[:alpha:]]/ &/g' > chain_${chain}/energy_breakdown_Xray_${chain}.dat

  #Plotting script setup
  path=$(dirname $0)
  cp -r ${path}/plot/plot_chain.gpt chain_${chain}
  sed -i "s/replace/${chain}/g" chain_${chain}/plot_chain.gpt
fi

# Loop through chain directories

while read p ; do

  cd $p
  echo ""
  echo "============================================"
  echo "Working in directory: ${p}"
  echo "============================================"
  echo ""

  iter=1
  # Loop through chain data and extract resi1, resi2 and total rosetta energy unit (REU)
  for f in *.dat ; do

    echo "Working on file: ${f}"
    echo "============================================"
    name=$(basename ${f} .dat)
    chain=$(echo ${name} | sed 's/energy_breakdown_Xray_//g')
    fileno=$(echo ${iter})

    # Get minimum, maximum and total residue numbers
    NTres=$(cat ${f} | head -n 1 | awk {'print $1'})
    CTres=$(cat ${f} | tail -n 1 | awk {'print $1'})
    echo "N-terminal residue: ${NTres}"
    echo "C-terminal residue: ${CTres}"
    NOres=$(echo "${CTres}-${NTres}+1; scale=0" | bc)
    echo "Number of residues: ${NOres}"

    # Remove intramolecular contacts, and count number
    interno=$(cat ${f} | awk ' $2 != $4 ' | awk {'print $1'} | sort -g | wc -l)
    interres=$(cat ${f} | awk ' $2 != $4 ' | awk {'print $1'} | sort -ug)
    echo "Number of intermolecular contacts: ${interno}"

    intrano=$(cat ${f} | awk ' $2 = $4 ' | awk {'print $1'} | sort -g | wc -l)
    echo "Number of intramolecular contacts: ${intrano}"

    # Write intermolecular contacts to file
    cat ${f} | awk ' $2 != $4 ' > tmp.dat
    mv tmp.dat ${f}

    # Loop through residue range, sum energies from each intermolecular contact and write to new file
    echo ""
    echo "Calulating sum of intermolecular energy per residue..."
    echo "" > ${name}_sum.dat
    for r in $interres ; do
      # Only print current working residue, calculate mean energy
      #awk -v res=${r} ' $1 == res ' ${f} | awk -v res=${r} '{x+=$5; next} END{print res,x/NR}' >> ${name}_sum.dat
      # Only print current working residue, calculate summed energy
      awk -v res=${r} ' $1 == res ' ${f} | awk -v res=${r} '{sum+=$5}END{print res,sum;}' >> ${name}_sum.dat
      # Keep track of number of intermolecular contacts for the current working residue
      resno=$(awk -v res=${r} ' $1 == res ' ${f} | wc -l)
    done
    #Remove header
    sed -i '/^$/d' ${name}_sum.dat

    # Fill in blanks for full sequence range, residues with no intermolecular contacts are scored 0
    echo "Writing residue range energies from ${NTres} to ${CTres}... to file ${name}_sum_REU.dat"
    echo "" > ${name}_sum_REU.dat
    for r in `seq ${NTres} ${CTres}` ; do
      #Get residue energy if it has one
      REU=$(awk -v res=${r} ' $1 == res ' ${name}_sum.dat | awk {'print $2'})
      if [[ -z $REU ]] ; then
        REU=$(printf "%.4f\n" 0)
      fi
      echo "$r $REU" >> ${name}_sum_REU.dat
    done
    #Remove header
    sed -i '/^$/d' ${name}_sum_REU.dat
    #Sanity check the number of lines in the contacts energy file
    tmp=$(wc -l ${name}_sum_REU.dat | awk {'print $1'})
    if [[ $NOres == $tmp ]] ; then
      echo ""
      echo "Number of residues recorded energy for (${tmp}): matches length of sequence, carry on..."
    else
      echo ""
      echo "Number of residues recorder energy for doesn't match sequence lenth"
      echo "Exiting...."
      exit
    fi

    # Create window average ala BUDE representation
    echo "Calculating 5 residue windows and single value averages..."
    echo "" > ${chain}-w5.txt
    echo "" > ${chain}-w5.dat
    i=1
    for r in `seq ${NTres} ${CTres}` ; do
      # Get window resiude range
      j=$(($i+4))
      r2=$(($r+4))
      # Calculate the sum/total energy over 5 residue windows
      search=$(awk -v res=${r} ' $1 == res ' ${name}_sum_REU.dat)  # Find unique line
      sum=$(grep -A 4 "$search" ${name}_sum_REU.dat | awk '{sum+=$2}END{print sum;}')       # Get 5 residue window sum
      # Print window info to file
      printf "${fileno} ${i} ${j} ${chain}${r}~${chain}${r2}\t${sum}\n" >> ${chain}-w5.txt

      # Get averaged from window residue information
      j2=$(($r+2))
      r3=$(printf "%.4f\n" $(echo "scale=4;(${sum}/5)" | bc))
      # Print averaged window data to file
      printf "${chain}\t${j2}\t${r3}\n" >> ${chain}-w5.dat

      i=$(($i+1))
    done
    #Remove header
    sed -i '/^$/d' ${chain}-w5.txt
    sed -i '/^$/d' ${chain}-w5.dat

    echo "============================================"
    echo ""

  iter=$(($iter+1))

  done

  # plot!!
  echo ""
  echo "Plotting data..."
  gnuplot < *.gpt

  cd ..

done < .dir_list

exit

# Combine and average appropriate chain data
echo "Aggregating data for chains..."
paste -d " " *A_sum_res.dat *A_sum_REU.dat *F_sum_REU.dat *K_sum_REU.dat > energy_breakdown_Xray_AFK.dat
paste -d " "  *B_sum_res.dat *B_sum_REU.dat *G_sum_REU.dat *L_sum_REU.dat > energy_breakdown_Xray_BGL.dat
paste -d " "  *C_sum_res.dat *C_sum_REU.dat *H_sum_REU.dat *M_sum_REU.dat > energy_breakdown_Xray_CHM.dat
paste -d " "  *D_sum_res.dat *D_sum_REU.dat *I_sum_REU.dat *N_sum_REU.dat > energy_breakdown_Xray_DIN.dat
paste -d " "  *E_sum_res.dat *E_sum_REU.dat *J_sum_REU.dat *O_sum_REU.dat > energy_breakdown_Xray_EJO.dat

echo "Averaging data for chains..."
awk {'print $1,$2+$3+$4/3'} energy_breakdown_Xray_AFK.dat > energy_breakdown_Xray_AFK_av.dat
awk {'print $1,$2+$3+$4/3'} energy_breakdown_Xray_BGL.dat > energy_breakdown_Xray_BGL_av.dat
awk {'print $1,$2+$3+$4/3'} energy_breakdown_Xray_CHM.dat > energy_breakdown_Xray_CHM_av.dat
awk {'print $1,$2+$3+$4/3'} energy_breakdown_Xray_DIN.dat > energy_breakdown_Xray_DIN_av.dat
awk {'print $1,$2+$3+$4/3'} energy_breakdown_Xray_EJO.dat > energy_breakdown_Xray_EJO_av.dat
