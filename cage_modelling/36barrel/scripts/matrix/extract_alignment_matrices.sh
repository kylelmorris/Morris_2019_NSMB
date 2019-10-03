#!/bin/bash
#

# Split RMSD_alignment_matrix into seperate matrices
csplit -k RMSD_alignment_matrix --prefix='map_alignment_matrix.' --suffix-format='%03d.mat' --elide-empty-files '/Model/' '{*}'

# Remove refPDB alignment matrix, not required
rm -rf map_alignment_matrix.000.mat

# Replace model identifier with model 999.0 corresponding to map in chimera sessions
for f in *.mat ; do
  cat ${f} | grep -v Model | sed '1s/^/Model 999.0\n/' > .tmp.dat
  mv .tmp.dat ../mapCC/matrix/${f}
done

# Tidy up
rm -rf map_alignment_matrix*