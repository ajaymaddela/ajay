#!/bin/bash


if [ ! -f "$1" ];
then 
  echo "the input to $0 should be a file"
fi 
echo "the following serversare up $(date +%x)" > checkservers.out
while read server;
do 
   ping -c1 "server"&& echo "serverup $server" >> checkservers.out
done < $1
