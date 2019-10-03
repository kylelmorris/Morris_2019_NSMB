#!/bin/bash

#Remove existing movies
rm -rf ./PDB_built_final_geometry_all/movies_legs/*mp4
rm -rf ./PDB_built_final_geometry_all/*mp4

# Get map info
map=$(cat map/.map_info | grep Map | awk {'print $2'})

# Encode movie for all images of legs saved from 5_TS_measure_RMSD_and_map_CC.py
ffmpeg -loglevel panic -framerate 1 -pattern_type glob -i "./PDB_built_final_geometry_all/movies_legs/*.png" -c:v libx264 -r 30 -pix_fmt yuv420p "./PDB_built_final_geometry_all/${map}_legs_movie.mp4"

# Encode movie for all images of cage saved from 5_TS_measure_RMSD_and_map_CC.py
ffmpeg -loglevel panic -framerate 1 -pattern_type glob -i "./PDB_built_final_geometry_all/movies_cage/*.png" -c:v libx264 -r 30 -pix_fmt yuv420p "./PDB_built_final_geometry_all/${map}_cage_movie.mp4"

# Put movies side by side
ffmpeg \
  -i "./PDB_built_final_geometry_all/${map}_cage_movie.mp4" \
  -i "./PDB_built_final_geometry_all/${map}_legs_movie.mp4" \
  -filter_complex '[0:v]pad=iw*2:ih[int];[int][1:v]overlay=W/2:0[vid]' \
  -map [vid] \
  -c:v libx264 \
  -crf 23 \
  -preset veryfast \
  "./PDB_built_final_geometry_all/${map}_leg_geometry_all.mp4"
