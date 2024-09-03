#!/bin/bash

# Source the configuration file
source ./config.txt

# Function to get the current record value
get_current_record_value1() {
  local profile=$1
  local subdomain1=$2
  local hosted_zone_id=$3
  aws route53 list-resource-record-sets \
    --hosted-zone-id "$hosted_zone_id" \
    --query "ResourceRecordSets[?Name == '${subdomain1}.'].ResourceRecords[0].Value" \
    --output text \
    --profile "$profile"
}

# Update DNS records for first set of subdomains
for PROFILE in "${PROFILES[@]}"; do
  echo "Processing profile: $PROFILE"

  # Update SUBDOMAIN1
  CURRENT_TARGET=$(get_current_record_value1 "$PROFILE" "$SUBDOMAIN1" "$HOSTED_ZONE_ID")
  if [ -z "$CURRENT_TARGET" ]; then
      echo "Record not found for SUBDOMAIN1 $SUBDOMAIN1 in profile $PROFILE"
  elif [ "$CURRENT_TARGET" == "$NEW_TARGET1" ]; then
      echo "Record for $SUBDOMAIN1 already exists with target $NEW_TARGET1 in profile $PROFILE"
  else
    CHANGE_BATCH=$(cat <<EOF
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
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$CHANGE_BATCH" \
        --profile "$PROFILE"
    echo "DNS record updated for $SUBDOMAIN1 to point to $NEW_TARGET1 in profile $PROFILE"
  fi
done

get_current_record_value2() {
  local profile=$1
  local subdomain2=$2
  local hosted_zone_id=$3
  aws route53 list-resource-record-sets \
    --hosted-zone-id "$hosted_zone_id" \
    --query "ResourceRecordSets[?Name == '${subdomain2}.'].ResourceRecords[0].Value" \
    --output text \
    --profile "$profile"
}

# Update DNS records for second set of subdomains
for PROFILE in "${PROFILES[@]}"; do
  echo "Processing profile: $PROFILE"

  CURRENT_TARGET=$(get_current_record_value2 "$PROFILE" "$SUBDOMAIN2" "$HOSTED_ZONE_ID")
  if [ -z "$CURRENT_TARGET" ]; then
      echo "Record not found for SUBDOMAIN2 $SUBDOMAIN2 in profile $PROFILE"
  elif [ "$CURRENT_TARGET" == "$NEW_TARGET2" ]; then
      echo "Record for $SUBDOMAIN2 already exists with target $NEW_TARGET2 in profile $PROFILE"
  else
    CHANGE_BATCH=$(cat <<EOF
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
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$CHANGE_BATCH" \
        --profile "$PROFILE"
    echo "DNS record updated for $SUBDOMAIN2 to point to $NEW_TARGET2 in profile $PROFILE"
  fi
done

get_current_record_value3() {
  local profile=$1
  local subdomain3=$2
  local hosted_zone_id=$3
  aws route53 list-resource-record-sets \
    --hosted-zone-id "$hosted_zone_id" \
    --query "ResourceRecordSets[?Name == '${subdomain3}.'].ResourceRecords[0].Value" \
    --output text \
    --profile "$profile"
}

# Update DNS records for third set of subdomains
for PROFILE in "${PROFILES[@]}"; do
  echo "Processing profile: $PROFILE"

  CURRENT_TARGET=$(get_current_record_value3 "$PROFILE" "$SUBDOMAIN3" "$HOSTED_ZONE_ID")
  if [ -z "$CURRENT_TARGET" ]; then
      echo "Record not found for SUBDOMAIN3 $SUBDOMAIN3 in profile $PROFILE"
  elif [ "$CURRENT_TARGET" == "$NEW_TARGET3" ]; then
      echo "Record for $SUBDOMAIN3 already exists with target $NEW_TARGET3 in profile $PROFILE"
  else
    CHANGE_BATCH=$(cat <<EOF
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
    aws route53 change-resource-record-sets \
        --hosted-zone-id "$HOSTED_ZONE_ID" \
        --change-batch "$CHANGE_BATCH" \
        --profile "$PROFILE"
    echo "DNS record updated for $SUBDOMAIN3 to point to $NEW_TARGET3 in profile $PROFILE"
  fi
done

# Update DNS records for another account
# for PROFILE in "${PROFILES1[@]}"; do
#   echo "Processing profile: $PROFILE"

#   CURRENT_TARGET=$(get_current_record_value "$PROFILE" "$SUBDOMAIN8" "$HOSTED_ZONE_ID1")
#   if [ -z "$CURRENT_TARGET" ]; then
#       echo "Record not found for SUBDOMAIN8 $SUBDOMAIN8 in profile $PROFILE"
#   elif [ "$CURRENT_TARGET" == "$NEW_TARGET8" ]; then
#       echo "Record for $SUBDOMAIN8 already exists with target $NEW_TARGET8 in profile $PROFILE"
#   else
#     CHANGE_BATCH=$(cat <<EOF
# {
#   "Changes": [
#     {
#       "Action": "UPSERT",
#       "ResourceRecordSet": {
#         "Name": "${SUBDOMAIN8}",
#         "Type": "CNAME",
#         "TTL": 300,
#         "ResourceRecords": [
#           {
#             "Value": "${NEW_TARGET8}"
#           }
#         ]
#       }
#     }
#   ]
# }
# EOF
#   )
#     aws route53 change-resource-record-sets \
#         --hosted-zone-id "$HOSTED_ZONE_ID1" \
#         --change-batch "$CHANGE_BATCH" \
#         --profile "$PROFILE"
#     echo "DNS record updated for $SUBDOMAIN8 to point to $NEW_TARGET8 in profile $PROFILE"
#   fi
# done
