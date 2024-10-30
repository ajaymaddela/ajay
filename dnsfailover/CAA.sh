#!/bin/bash

# Check for the correct number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <subdomain> <hosted_zone_id> <caa_value>"
    exit 1
fi

SUBDOMAIN=$1
HOSTED_ZONE_ID=$2
CAA_VALUE=$3

# Create the change batch JSON using a variable
CHANGE_BATCH_JSON=$(cat <<EOF
{
  "Comment": "Updating CAA record for $SUBDOMAIN",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "$SUBDOMAIN",
        "Type": "CAA",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "$CAA_VALUE"
          }
        ]
      }
    }
  ]
}
EOF
)

# Run the AWS CLI command to update the CAA record
aws route53 change-resource-record-sets \
    --hosted-zone-id "$HOSTED_ZONE_ID" \
    --change-batch "$CHANGE_BATCH_JSON"

echo "CAA record for $SUBDOMAIN updated successfully."
