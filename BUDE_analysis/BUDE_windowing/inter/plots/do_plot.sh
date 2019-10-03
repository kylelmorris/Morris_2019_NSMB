#!/bin/bash

# Plot the windowing data:

gnuplot plot_AFK.gpt
gnuplot plot_BGL.gpt
gnuplot plot_CHM.gpt
gnuplot plot_DIN.gpt
gnuplot plot_EJO.gpt
ps2pdf AFK-energy-w5.ps
ps2pdf BGL-energy-w5.ps
ps2pdf CHM-energy-w5.ps
ps2pdf DIN-energy-w5.ps
ps2pdf EJO-energy-w5.ps
