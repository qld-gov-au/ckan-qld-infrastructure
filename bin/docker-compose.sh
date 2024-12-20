#!/bin/sh

set -x

if (docker compose ls >/dev/null); then
    # Docker Compose v2
    docker compose $*
else
    # Docker Compose not found
    exit 1
fi
