#!/bin/bash

rm -rf temps
rmdir_rc=$?



if [[ ${rmdir_rc} -ne 0 ]]; then
   echo "rmdir is not created so stop it"
   exit 1
fi
 
  
  exit 0