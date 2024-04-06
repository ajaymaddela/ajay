
LOCATION=$1
group=renuka
vnetname=vnet1
address=192.168.0.0/16
subnetname=web


[ -z $LOCATION ] && LOCATION="eastus"



group=$(az group create \
         --name ${group} \
         --location ${LOCATION})


nat=$(az network nat gateway create \
 --resource-group ${group} \
 --name ajay \
 --public-ip-prefixes 192.168.0.0/21 \
 --public-ip-addresses public-ip-nat \
 --idle-timeout 10 \
 --location ${LOCATION})

vnet=$(az network vnet create \
       --name ${vnetname} \
       --resource-group ${group} \
       --address-prefixes ${address} \
       --location ${LOCATION} \
       --subnet-name ${subnetname} \
       --subnet-prefixes 192.168.0.0/24 \
       --nat-gateway ajay)