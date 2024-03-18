#!/bin/bash

###############################################################################
# author: ajay
# course: azure
# location: ameerpet
# usage: ./defaultval.sh <name> <course>
###############################################################################

if [[ $# -ne 2 ]]; then
   echo "incorect number of count"
   echo "usage: ./defaultval.sh <name> <course>"
   exit 1
fi 
 
 name=$1
 cousre=$2

 [ -z $name ] && name="ajay"
 [ -z $course ] && course="linux"

 echo "hi ${name} welcome to world of ${course}"