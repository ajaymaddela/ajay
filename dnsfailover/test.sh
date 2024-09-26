#!/bin/bash

# Function to check DNS record types in Route 53 and return only the type
get_route53_record_type() {
    local zone_id=$1
    local record_name=$2

    if [ -z "$zone_id" ] || [ -z "$record_name" ]; then
        echo "Usage: get_route53_record_type <zone_id> <record_name>"
        return 1
    fi

    echo "Fetching record types for $record_name in zone $zone_id..."

    # Querying for record types
    aws route53 list-resource-record-sets --hosted-zone-id "$zone_id" --query "ResourceRecordSets[?Name == \`${record_name}.\`].Type" --output text --profile sandbox
}
