#!/bin/bash

# Set the environment variables, just to mute the warnings
export USER_UID=$(id -u)
export USER_GID=$(id -g)

docker compose run --rm nvim-devcontainer
