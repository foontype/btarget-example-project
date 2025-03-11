#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_CASHES}" ]; then
    chown -R "${CONTAINER_USER}" ./run/devcontainer/.cache
fi
