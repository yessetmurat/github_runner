#!/bin/bash

# Ensure required environment variables are set
if [ -z "$OWNER" ] || [ -z "$REPOSITORY" ] || [ -z "$TOKEN" ]; then
    echo "Error: OWNER, REPOSITORY, and TOKEN environment variables must be set."
    exit 1
fi

# Generate a unique runner name
RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="containerNode-$RUNNER_SUFFIX"

# Fetch the registration token from GitHub's API
REG_TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" \
                         -H "Authorization: token $TOKEN" \
                         "https://api.github.com/repos/$OWNER/$REPOSITORY/actions/runners/registration-token")
if [ $? -ne 0 ]; then
    echo "Error: Failed to get registration token from GitHub."
    exit 1
fi

# Extract the token using jq
if ! REG_TOKEN=$(echo $REG_TOKEN | jq .token --raw-output); then
    echo "Error: Failed to parse registration token."
    exit 1
fi

# Change to the runner's directory
cd /home/runner/actions-runner || exit

# Configure the runner
./config.sh --unattended --url "https://github.com/$OWNER/$REPOSITORY" \
            --token "$REG_TOKEN" --labels linux,ubuntu --name "$RUNNER_NAME" || exit

# Define a cleanup function
cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token "$REG_TOKEN"
}

# Set trap handlers
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# Start the runner
./run.sh & wait $!
