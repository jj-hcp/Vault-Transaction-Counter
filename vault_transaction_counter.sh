#!/bin/bash

#Edit the LOG_FILE variable below
#Make the script executable (chmod +x vault_transaction_counter.sh
#Run the script with optional start date variable: ./vault_transaction_counter.sh OR ./vault_transaction_counter.sh YYYY-MM-DD e.g. ./vault_transaction_counter.sh 2024-01-01

# Define the path to the log file
LOG_FILE="/var/log/audit.log"

# Check if a start date argument is provided
if [ "$#" -eq 1 ]; then
    start_date="${1}T00:00:00Z"
    # Use jq to filter based on the provided start date
    filter_condition='select(.time >= $start_date)'
else
    start_date=""
    # No filtering based on date
    filter_condition='.'
fi

# Count the lines that are of type 'response' with a 'client_token' in the response section, successful logins is the only time the client_token is within the response
login_count=$(jq -c --arg start_date "$start_date" "$filter_condition | select(.type == \"response\" and .response.auth.client_token != null)" "$LOG_FILE" | wc -l)

# Count the lines that are of type 'request' with a non-null 'client_token'
request_count=$(jq -c --arg start_date "$start_date" "$filter_condition | select(.type == \"request\" and .auth.client_token != null)" "$LOG_FILE" | wc -l)

# Sum the counts
total_count=$((login_count + request_count))

# Print the counts
echo "Number of login transactions: $login_count"
echo "Number of token transactions: $request_count"
echo "Total transactions:           $total_count"
