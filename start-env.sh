#!/bin/bash

# Check if the user has provided an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <service_to_start>"
  exit 1
fi

# Set the environment variables, just to mute the warnings
export USER_UID=$(id -u)
export USER_GID=$(id -g)

docker compose run --rm "$1"
