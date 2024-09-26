#!/bin/bash

# Source the configuration file
source ./config.txt

# Declare associative arrays for subdomains and new targets
declare -A subdomains
declare -A new_targets

subdomains["subdomain1"]=$SUBDOMAIN1
new_targets["subdomain1"]=$NEW_TARGET1
subdomains["subdomain2"]=$SUBDOMAIN2
new_targets["subdomain2"]=$NEW_TARGET2
subdomains["subdomain3"]=$SUBDOMAIN3
new_targets["subdomain3"]=$NEW_TARGET3

# Function to get the current record value
get_current_record_value() {
  local profile=$1
  local subdomain=$2
  local hosted_zone_id=$3

  # Check for standard record value
  standard_record_value=$(aws route53 list-resource-record-sets \
    --hosted-zone-id "$hosted_zone_id" \
    --query "ResourceRecordSets[?Name == '${subdomain}.'].ResourceRecords[0].Value" \
    --output text \
    --profile "$profile")

  # If standard record value is empty, check for alias record
  if [ -z "$standard_record_value" ]; then
    alias_record_dns_name=$(aws route53 list-resource-record-sets \
      --hosted-zone-id "$hosted_zone_id" \
      --query "ResourceRecordSets[?Name == '${subdomain}.'].AliasTarget.DNSName" \
      --output text \
      --profile "$profile")

    # Output alias record DNS name if found
    if [ -n "$alias_record_dns_name" ]; then
      echo "$alias_record_dns_name"
    else
      echo ""
    fi
  else
    # Output standard record value if found
    echo "$standard_record_value"
  fi
}

# Function to delete existing alias records
delete_existing_records() {
  local profile=$1
  local subdomain=$2
  local existing_record_value=$3

  # Only delete alias records
  CHANGE_BATCH=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "DELETE",
      "ResourceRecordSet": {
        "Name": "${subdomain}",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "$HOSTED_ZONE_ID",
          "DNSName": "$existing_record_value",
          "EvaluateTargetHealth": true
        }
      }
    }
  ]
}
EOF
  )
  aws route53 change-resource-record-sets \
      --hosted-zone-id "$HOSTED_ZONE_ID" \
      --change-batch "$CHANGE_BATCH" \
      --profile "$profile"
  echo "Existing alias A record for $subdomain deleted in profile $profile."
}

subdomain_list=(subdomain1 subdomain2 subdomain3)
# Update DNS records for the subdomains
for subdomain_key in "${subdomain_list[@]}"; do
  SUBDOMAIN=${subdomains[$subdomain_key]}   # Correctly access the associative array
  NEW_TARGET=${new_targets[$subdomain_key]} # Correctly access the associative array

  # Ensure SUBDOMAIN and NEW_TARGET are not empty
  if [ -z "$SUBDOMAIN" ]; then
    echo "Subdomain for $subdomain_key is empty."
    continue
  fi
  if [ -z "$NEW_TARGET" ]; then
    echo "New target for $subdomain_key is empty."
    continue
  fi

  for PROFILE in "${PROFILES[@]}"; do
    echo "Processing profile: $PROFILE for $SUBDOMAIN"

    CURRENT_TARGET=$(get_current_record_value "$PROFILE" "$SUBDOMAIN" "$HOSTED_ZONE_ID")
    if [ -z "$CURRENT_TARGET" ]; then
      echo "Record not found for $SUBDOMAIN in profile $PROFILE"
    elif [ "$CURRENT_TARGET" == "$NEW_TARGET" ]; then
      echo "Record for $SUBDOMAIN already exists with target $NEW_TARGET in profile $PROFILE"
    else 
      # Get the standard record value
      
      

      record_type=$(aws route53 list-resource-record-sets --hosted-zone-id "$HOSTED_ZONE_ID" --query "ResourceRecordSets[?Name == \`
"${SUBDOMAIN}".\`].Type" --output text --profile "$PROFILE")
      # If standard_record_value is found, skip deletion of alias records
      if [ $record_type == "A" ]; then
        # Existing record is an alias, delete it
        delete_existing_records "$PROFILE" "$SUBDOMAIN" "$CURRENT_TARGET"
      fi
      

      # Create the new CNAME record, regardless of deletion
      CHANGE_BATCH=$(cat <<EOF
{
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "${SUBDOMAIN}",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "${NEW_TARGET}"
          }
        ]
      }
    }
  ]
}
EOF
      )
      aws route53 change-resource-record-sets \
          --hosted-zone-id "$HOSTED_ZONE_ID" \
          --change-batch "$CHANGE_BATCH" \
          --profile "$PROFILE"
      echo "DNS record updated for $SUBDOMAIN to point to $NEW_TARGET in profile $PROFILE"
    fi
  done
done
