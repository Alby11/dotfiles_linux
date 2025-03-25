#!/bin/sh
# vim: set ft=sh

# Function to check if internet is available
check_internet() {
  timeout 2 ping -c 1 8.8.8.8 >/dev/null 2>&1
  return $?
}

# Log file location for debugging
log_file="${HOME}/.var/log/fetch_secrets.log"
mkdir -p "$(dirname "$log_file")"

# Loop with retry limit until internet connection is available
max_retries=20
retries=0

until check_internet; do
  echo "Waiting for internet connection..." >>"$log_file"
  sleep 1
  retries=$((retries + 1))
  if [ "$retries" -ge "$max_retries" ]; then
    echo "Internet connection not available. Skipping secrets fetching." >>"$log_file"
    exit 0
  fi
done

echo "Internet connection established. Fetching secrets..." >>"$log_file"

# Once internet is available, fetch and output export commands
for secret in $(aws secretsmanager list-secrets --output json | jq -r '.SecretList[] | @base64'); do
  _jq() {
    echo "${secret}" | base64 --decode | jq -r "${1}"
  }

  secret_name=$(_jq '.Name')
  secret_value=$(aws secretsmanager get-secret-value --secret-id "${secret_name}" | jq -r ".SecretString")

  # Output export commands for each secret
  echo "$secret_value" | jq -r 'to_entries | .[] | "export \(.key)=\(.value)"'
done
