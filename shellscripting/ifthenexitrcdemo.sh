#!/bin/bash

mkdir temps
mkdir_rc=$?



if [[ ${mkdir_rc} -ne 0 ]]; then
   echo "mkdir is not created so stop it"
   exit 1
fi

  touch temps/tmp1.txt 
  exit 0