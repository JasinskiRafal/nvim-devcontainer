#!/bin/bash

export USER_UID=$(id -u)
export USER_GID=$(id -g)

docker compose run --rm config
