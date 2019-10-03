#!/bin/bash
#

/Applications/Chimera.app/Contents/MacOS//chimera 0_build.py

/Applications/Chimera.app/Contents/MacOS//chimera 1_build_final_fragment_fit.py
/Applications/Chimera.app/Contents/MacOS//chimera 2_build_final_measure_angles.py
bash 3_build_final_geometry_sort.sh

/Applications/Chimera.app/Contents/MacOS//chimera 6_build_final_geometry_RMSD_mapCC.py
bash 7_build_final_geometry_RMSD_mapCC_analyse.sh
/Applications/Chimera.app/Contents/MacOS//chimera 8_build_final_contacts.py

python 4_build_final_geometry_plot_angles.py
python 5_build_final_geometry_plot_torsions.py

exit

/Applications/Chimera.app/Contents/MacOS//chimera 9_build_final_geometry_contacts.py
/Applications/Chimera.app/Contents/MacOS//chimera 10_build_final_make_movies.py
/Applications/Chimera.app/Contents/MacOS//chimera 11_leg_and_cage_images.py

bash build_final_contacts_plot.sh
