#!/bin/bash

###############################################################################
# author: ajay
# version: v1.0.0
# organization: quality thought
# location: ameerpet
# usage: ./create.sh <directory-path> <file-name> <file-content>
###############################################################################

# we need 3 arguments ,so check
# is 3 or not

if [[ $# -ne 3 ]]; then
   echo "incorect number of count"
   echo "usage: ./create.sh <directory-name> <file-name> <file-content>"
   exit 1
fi 

# paameters with argument values
directory_name=$1
file_name=$2
file_content=$3


# check if the directory exists, if not create directory
if [[ ! -d ${directory_name} ]]; then 
   mkdir ${directory_name} || { echo "cannot create directory"; exit 1; }
fi 

# lets create absolute file path
abs_file_path=${directory_name}/${file_name}

# try to create a file if file not exists
if [[ ! -f ${abs_file_path} ]]; then
  touch ${abs_file_path} || { echo "cannot create a file"; exit 1;}
fi
# since file is created or present add the contents to it
echo ${file_content} > ${abs_file_path}