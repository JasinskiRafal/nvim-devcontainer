#!/bin/bash

# Set the environment variables
export USER_UID=$(id -u)
export USER_GID=$(id -g)

# Run the docker compose build command with the user-provided argument
docker compose build base-image && \
docker compose build devcontainer


