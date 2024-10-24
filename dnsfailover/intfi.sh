#!/bin/bash

# Input files
A_RECORDS_FILE="A_records.txt"
CNAME_RECORDS_FILE="Cname_records.txt"

# Output files for failed attempts
A_FAIL_FILE="Afail.txt"
CNAME_FAIL_FILE="Cnamefail.txt"
INTRAFI_FILE="IntraFi.txt"

# Clear existing fail files
> "$A_FAIL_FILE"
> "$CNAME_FAIL_FILE"
> "$INTRAFI_FILE"

# Max concurrent jobs
MAX_JOBS=10
declare -a pids

# Function to check SSL certificates
check_ssl() {
    DOMAIN="$1"
    TYPE="$2"

    # # Check if the domain is reachable
    # if ! echo | nc -z "${DOMAIN}" 443; then
    #     if [[ "$TYPE" == "A" ]]; then
    #         echo "${DOMAIN} (not reachable)" >> "$A_FAIL_FILE"
    #     else
    #         echo "${DOMAIN} (not reachable)" >> "$CNAME_FAIL_FILE"
    #     fi
    #     return
    # fi
    
    # Get the certificate information using OpenSSL
    CERT_INFO=$(echo | openssl s_client -connect "${DOMAIN}:443" -servername "${DOMAIN}" 2>/dev/null | openssl x509 -text 2>/dev/null)

    # Check if certificate info was retrieved
    if [[ -z "$CERT_INFO" ]]; then
        if [[ "$TYPE" == "A" ]]; then
            echo "${DOMAIN}" >> "$A_FAIL_FILE"
        else
            echo "${DOMAIN}" >> "$CNAME_FAIL_FILE"
        fi
        return
    fi
    
    # Extract issuer information
    ISSUER=$(echo "$CERT_INFO" | grep "Issuer:")
    if [[ -z "$ISSUER" ]]; then
        if [[ "$TYPE" == "A" ]]; then
            echo "${DOMAIN}" >> "$A_FAIL_FILE"
        else
            echo "${DOMAIN}" >> "$CNAME_FAIL_FILE"
        fi
        return
    fi

    # Check for specific issuers
    if echo "$ISSUER" | grep -qE "IntraFi|Digicert|Let's Encrypt|GoDaddy.com"; then
        echo "${DOMAIN}" >> "$INTRAFI_FILE"
    fi
}

# Read A records and CNAME records
mapfile -t A_DOMAINS < "$A_RECORDS_FILE"
mapfile -t CNAME_DOMAINS < "$CNAME_RECORDS_FILE"

# Combine both A and CNAME domains into a single array for parallel processing
DOMAINS=("${A_DOMAINS[@]}" "${CNAME_DOMAINS[@]}")
TYPES=( "A" "CNAME" )

# Process all domains in parallel
for DOMAIN in "${DOMAINS[@]}"; do
    if [[ " ${A_DOMAINS[*]} " == *" $DOMAIN "* ]]; then
        TYPE="A"
    else
        TYPE="CNAME"
    fi
    
    {
        check_ssl "$DOMAIN" "$TYPE"
    } &
    pids+=($!)

    # Limit concurrent jobs
    if [[ ${#pids[@]} -ge $MAX_JOBS ]]; then
        wait -n
        # Remove the finished PID from the array
        pids=("${pids[@]:1}")
    fi
done

# Wait for all remaining jobs to finish
wait

echo "Processing completed."
