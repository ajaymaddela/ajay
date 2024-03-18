#!/bin/bash

file=randomfile.txt

#check file exists

if [[ ! -f ${file} ]]; then
  echo "file mentioned ${file} doesnt exists"
  exit 1
else 
   echo "printing content of ${file}"
   cat ${file}
   exit 0
fi