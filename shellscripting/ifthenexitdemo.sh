#!/bin/bash

###############################################################################
# author: ajay
# version: v1.0.0
# organization: quality thought
# location: ameerpet
###############################################################################

file="/tmp/random.txt"


if [[ -f ${file} ]]; then
  cat ${file}
  exit 0
fi

 exit 1
