#!/bin/bash

# Compiles this code!

gfortran mk_wins.f -o mk_wins
mv mk_wins ../bin

gfortran bude_scan_inter.f -o bude_scan_inter
mv bude_scan_inter ../bin


