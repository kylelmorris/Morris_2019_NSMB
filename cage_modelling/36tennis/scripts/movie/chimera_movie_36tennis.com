## Open maps

open /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_28mini/1-build_TS/map/postprocess_masked.mrc
open /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_36barrel/1-build_TS/map/postprocess_masked_flipZ.mrc
open /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_36tennis/1-build_TS/map/postprocess_masked.mrc

# Open models
#open /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_28mini/4-build_TS_reviewed/PDB_built_final/*pdb
#open /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_36barrel/4-build_TS_reviewed/PDB_built_final/*pdb
open /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_36tennis/4-build_TS_reviewed/PDB_built_final/*pdb

## Scene setup

volume #0 sdLevel 3 color grey transparency 0.5
volume #1 sdLevel 3 color grey transparency 0.5
volume #2 sdLevel 3 color grey transparency 0.5

windowsize 1000 1000; reset; focus; scale 0.9

## Chose map that you're making a movie of

~modeldisplay #0
~modeldisplay #1
modeldisplay #2

alias ^color_chc color #F49AEB $1:1-330; color #fb9a99 $1:331-838; color #6a3d9a $1:839-1074; color #6a3d9a $1:1075-1198; color #1F78B4 $1:1199-1576; color #da0048 $1:1577-1675; color #ADD8E6 $1:.D:.I:.N:.O:.E:.J

color_chc #3-150; color #ADD8E6 #3-150:.F

~silhouette

## Make movie

#Labels
#2dlabels delete label1
#2dlabels create label1 color black size 40 xpos 0.03 ypos 0.03 text "28 mini coat"
#2dlabels create label1 color black size 40 xpos 0.03 ypos 0.03 text "36 barrel"
2dlabels create label1 color black size 40 xpos 0.03 ypos 0.03 text "36 tennis ball"

# Scale bar
#2dlabels delete scale
2dlabels create scale color black size 40 xpos 0.87 ypos 0.06 text "250 Å"
close #999; shape rectangle color black width 250 height 10 center #1 modelId 999; move 290,-410,0 models #999

#Spin movie
movie record
turn y 1 360 center #0 models #0-200
wait
wait 25
turn x 1 360 center #0 models #0-200
wait
wait 25
movie stop

#movie encode /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_28mini/4-build_TS_reviewed/movie/spin_model.mp4 quality highest resetMode clear
#movie encode /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_36barrel/4-build_TS_reviewed/movie/spin_model.mp4 quality highest resetMode clear
movie encode /Users/kylemorr/Dropbox/_Krios_CHC/MODELLING/whole_cage/pflip_map_PDB_36tennis/4-build_TS_reviewed/movie/spin_model.mp4 quality highest resetMode clear

wait
