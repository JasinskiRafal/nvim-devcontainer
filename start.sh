#!/bin/bash

# Set the environment variables
export USER_UID=$(id -u)
export USER_GID=$(id -g)

docker compose run --rm devcontainer
