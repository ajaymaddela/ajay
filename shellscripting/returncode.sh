#!/bin/bash

###############################################################################
# author: ajay
# version: v1.0.0
# organization: quality thought
# location: ameerpet
###############################################################################

home_dir="/home/ubuntu"

# full check
test -d ${home_dir}

# returncode for full hand
full_check_rc=$?

# short hand
[ -d ${home_dir} ]

# return code for short hand 
short_check_rc=$?

echo "return code for full hand -d ${full_check_rc}"

echo "rteurn code for short hand [] ${short_check_rc}"