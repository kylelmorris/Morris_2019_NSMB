#!/bin/bash
#

##Get cage type
#Test if cage info exists
if [[ ! -f scripts/.info ]]; then
    echo "Cage info in scripts/.info not found"
    echo "Exiting..."
    exit
fi

# Get cage type stored by previous scripts
cage=$(grep cage scripts/.info | awk '{print $2}')
if [[ -z ${cage} ]]; then
    echo "Cage info absent in scripts/.info"
    echo "Exiting..."
    exit
fi

## Plot for all cage contacts
# Convert log file to a csv for plotting
cd PDB_built_final_contacts
bash ../scripts/contacts/extract_contacts_as_csv.sh all_contacts.log
cd all_contacts
# Plot
module load anaconda3
python ../../scripts/contacts/seaborn_contacts_plot.py --t ${cage}_contacts --i contacts.csv
cd ../..

## Plot for individual leg contacts
# Convert to csv and plot is contained in a single script
bash ./scripts/contacts/extract_contacts_as_csv_per_geom.sh
