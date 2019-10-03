#!/bin/bash
#

echo "RMSD averages over all stuctures with a geometry class" > ./PDB_built_final_geometry/all_RMSD_averages.log
echo "" >> ./PDB_built_final_geometry/all_RMSD_averages.log

for dir in ./PDB_built_final_geometry/* ; do
    if [ -d "${dir}" ]; then
        echo "${dir}" >> ./PDB_built_final_geometry/all_RMSD_averages.log
	      echo "Calculating average and standard deviation of all structure RMSD within geometry..." >> ./PDB_built_final_geometry/all_RMSD_averages.log
	      # Calculate average and standard deviation
	      # https://stackoverflow.com/questions/18786073/compute-average-and-standard-deviation-with-awk
	      cat ${dir}/RMSD/RMSD.log | awk '{print $7}' | sed '/^$/d' | awk -F ', '  '{   sum=sum+$0 ; sumX2+=(($0)^2)} END { avg=sum/NR; printf "Average: %f. Standard Deviation: %f \n", avg, sqrt(sumX2/(NR-1) - 2*avg*(sum/(NR-1)) + ((NR*(avg^2))/(NR-1)))}' >> ./PDB_built_final_geometry/all_RMSD_averages.log
	      echo "" >> ./PDB_built_final_geometry/all_RMSD_averages.log
    fi
done

echo "mapCC averages over all stuctures with a geometry class" > ./PDB_built_final_geometry/all_mapCC_averages.log
echo "" >> ./PDB_built_final_geometry/all_mapCC_averages.log
echo "#######################################################################################################" >> ./PDB_built_final_geometry/all_mapCC_averages.log
echo "Individual model-map CC about mean was found to be more sensitive to fitting errors, than about 0 mapCC" >> ./PDB_built_final_geometry/all_mapCC_averages.log
echo "Bad fits tend to have an order of magnitude worse CC about mean within a group, and are probably fitting outliers" >> ./PDB_built_final_geometry/all_mapCC_averages.log
echo "#######################################################################################################" >> ./PDB_built_final_geometry/all_mapCC_averages.log
echo "" >> ./PDB_built_final_geometry/all_mapCC_averages.log

for dir in ./PDB_built_final_geometry/* ; do
    if [ -d "${dir}" ]; then
        echo "${dir}" >> ./PDB_built_final_geometry/all_mapCC_averages.log
        echo "Average model-map cross correlations (about mean, not the 0) within geometry..." >> ./PDB_built_final_geometry/all_mapCC_averages.log
        cat ${dir}/mapCC/map_CC.log | awk '{print $14}' | sed '/^$/d' | sed 's/,//g' | awk -F ', '  '{   sum=sum+$0 ; sumX2+=(($0)^2)} END { avg=sum/NR; printf "Average: %f. Standard Deviation: %f \n", avg, sqrt(sumX2/(NR-1) - 2*avg*(sum/(NR-1)) + ((NR*(avg^2))/(NR-1)))}' >> ./PDB_built_final_geometry/all_mapCC_averages.log
        echo "" >> ./PDB_built_final_geometry/all_mapCC_averages.log
        echo "Reporting all model-map cross correlations (about 0) within geometry..." >> ./PDB_built_final_geometry/all_mapCC_averages.log
        cat ${dir}/mapCC/map_CC.log >> ./PDB_built_final_geometry/all_mapCC_averages.log
    fi
done

open ./PDB_built_final_geometry/all_RMSD_averages.log
open ./PDB_built_final_geometry/all_mapCC_averages.log
