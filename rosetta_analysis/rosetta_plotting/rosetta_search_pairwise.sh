#!/bin/bash
#

cat data/*dat | grep "${2}" | awk -v threshold=$1 ' $7 < threshold '
