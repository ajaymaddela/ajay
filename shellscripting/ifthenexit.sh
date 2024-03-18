#!/bin/bash

###############################################################################
# author: ajay
# version: v1.0.0
# organization: quality thought
# location: ameerpet
###############################################################################

mkdir=temps
mkdir_rc=$?

if [[ -d ${mkdir_rc} ]]; 
  then exit 0
fi

 exit 1
