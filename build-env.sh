#!/bin/bash

# Check if the user has provided an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <service_to_build>"
  exit 1
fi

# Set the environment variables
export USER_UID=$(id -u)
export USER_GID=$(id -g)

# Run the docker compose build command with the user-provided argument
docker compose build "$1"

