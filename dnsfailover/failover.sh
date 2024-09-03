#!/bin/bash

# Configuration
DOMAIN="intrafi.com"
SUBDOMAIN1="sub.$DOMAIN"
NEW_TARGET1="new.$DOMAIN"
HOSTED_ZONE_ID="Z03287222VWUPH1Z6FJ71" # Replace with your hosted zone ID
PROFILES=("sandbox")    #"account2" "account3" # Replace with your AWS CLI profiles

# Function to get the current record value
get_current_record_value() {
  local profile=$1
  local subdomain1=$2
  aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --query "ResourceRecordSets[?Name == '${subdomain1}.'].ResourceRecords[0].Value" \
    --output text \
    --profile "$profile"
}

# Loop through each profile and update the DNS record
for PROFILE in "${PROFILES[@]}"; do
  echo "Processing profile: $PROFILE"

  # Get the current target value
  CURRENT_TARGET=$(get_current_record_value "$PROFILE" "$SUBDOMAIN1")

  if [ -z "$CURRENT_TARGET" ]; then
      echo "Record not found for SUBDOMAIN1 $SUBDOMAIN1 in profile $PROFILE"
      
  elif [ "$CURRENT_TARGET" == "$NEW_TARGET1" ]; then
      echo "Record for $SUBDOMAIN1 already exists with target $NEW_TARGET1 in profile $PROFILE"
  else

  # Create the change batch JSON
  CHANGE_BATCH1=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${SUBDOMAIN1}",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${NEW_TARGET1}"
          }
        ]
      }
    }
  ]
}
EOF
  )

  # Update the DNS record
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$CHANGE_BATCH1" \
        --profile "$PROFILE"

     echo "DNS record updated for $SUBDOMAIN1 to point to $NEW_TARGET1 in profile $PROFILE"
  fi
done




#################################################################################
#for second subdomain

SUBDOMAIN2="latest.$DOMAIN"
NEW_TARGET2="newone.$DOMAIN"

# Function to get the current record value
get_current_record_value() {
  local profile=$1
  local subdomain2=$2
  aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --query "ResourceRecordSets[?Name == '${subdomain2}.'].ResourceRecords[0].Value" \
    --output text \
    --profile "$profile"
}

# Loop through each profile and update the DNS record
for PROFILE in "${PROFILES[@]}"; do
  echo "Processing profile: $PROFILE"

  # Get the current target value
  CURRENT_TARGET=$(get_current_record_value "$PROFILE" "$SUBDOMAIN2")

  if [ -z "$CURRENT_TARGET" ]; then
      echo "Record not found for SUBDOMAIN2 $SUBDOMAIN2 in profile $PROFILE"
  elif [ "$CURRENT_TARGET" == "$NEW_TARGET2" ]; then
      echo "Record for $SUBDOMAIN2 already exists with target $NEW_TARGET2 in profile $PROFILE"
  else


  # Create the change batch JSON
  CHANGE_BATCH2=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${SUBDOMAIN2}",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${NEW_TARGET2}"
          }
        ]
      }
    }
  ]
}
EOF
  )

  # Update the DNS record
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$CHANGE_BATCH2" \
        --profile "$PROFILE"

    echo "DNS record updated for $SUBDOMAIN2 to point to $NEW_TARGET2 in profile $PROFILE"
  fi
done


###################################################################################################

#for third subdomain

SUBDOMAIN3="lat.$DOMAIN"
NEW_TARGET3="latest.$DOMAIN"

# Function to get the current record value
get_current_record_value() {
  local profile=$1
  local subdomain3=$2
  aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --query "ResourceRecordSets[?Name == '${subdomain3}.'].ResourceRecords[0].Value" \
    --output text \
    --profile "$profile"
}

# Loop through each profile and update the DNS record
for PROFILE in "${PROFILES[@]}"; do
  echo "Processing profile: $PROFILE"

  # Get the current target value
  CURRENT_TARGET=$(get_current_record_value "$PROFILE" "$SUBDOMAIN3")

  if [ -z "$CURRENT_TARGET" ]; then
      echo "Record not found for SUBDOMAIN2 $SUBDOMAIN3 in profile $PROFILE"
  elif [ "$CURRENT_TARGET" == "$NEW_TARGET3" ]; then
      echo "Record for $SUBDOMAIN3 already exists with target $NEW_TARGET3 in profile $PROFILE"
  else


  # Create the change batch JSON
  CHANGE_BATCH3=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${SUBDOMAIN3}",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${NEW_TARGET3}"
          }
        ]
      }
    }
  ]
}
EOF
  )

  # Update the DNS record
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$CHANGE_BATCH3" \
        --profile "$PROFILE"

    echo "DNS record updated for $SUBDOMAIN3 to point to $NEW_TARGET3 in profile $PROFILE"
  fi
done


###################################################################################################
# for another account
# Configuration
DOMAIN1="ajay.com"
SUBDOMAIN8="new.$DOMAIN1"
NEW_TARGET8="latestajay.$DOMAIN1"
HOSTED_ZONE_ID1="Z08158762B3Z7JDEZXZZ3" # Replace with your hosted zone ID
PROFILES1=("testing")    #"account2" "account3" # Replace with your AWS CLI profiles

# Function to get the current record value
get_current_record_value() {
  local profile=$1
  local subdomain8=$2
  aws route53 list-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID1" \
    --query "ResourceRecordSets[?Name == '${subdomain8}.'].ResourceRecords[0].Value" \
    --output text \
    --profile "$profile"
}

# Loop through each profile and update the DNS record
for PROFILE in "${PROFILES1[@]}"; do
  echo "Processing profile: $PROFILE"

  # Get the current target value
  CURRENT_TARGET=$(get_current_record_value "$PROFILE" "$SUBDOMAIN8")

  if [ -z "$CURRENT_TARGET" ]; then
      echo "Record not found for SUBDOMAIN8 $SUBDOMAIN8 in profile $PROFILE"
  elif [ "$CURRENT_TARGET" == "$NEW_TARGET8" ]; then
      echo "Record for $SUBDOMAIN8 already exists with target $NEW_TARGET8 in profile $PROFILE"
  else

  # Create the change batch JSON
  CHANGE_BATCH8=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${SUBDOMAIN8}",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${NEW_TARGET8}"
          }
        ]
      }
    }
  ]
}
EOF
  )

  # Update the DNS record
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID1" \
        --change-batch "$CHANGE_BATCH8" \
        --profile "$PROFILE"

    echo "DNS record updated for $SUBDOMAIN8 to point to $NEW_TARGET8 in profile $PROFILE"
  fi
done