pdbin=$1

# Set up
rm -rf energy_scoring
mkdir energy_scoring

path=$(dirname $0)

# Energy scoring
residue_energy_breakdown.static.macosclangrelease \
-in:file:s $pdbin \
-out:file:silent ./energy_scoring/${pdbin}_energy_breakdown.out

# Energy scoring extract and plot
bash ${path}/rosetta_energy_score_plot.sh ./energy_scoring/${pdbin}_energy_breakdown.out
