#!/bin/bash

export USER_UID=$(id -u)
export USER_GID=$(id -g)

docker compose build base-image && \
docker compose build devcontainer


