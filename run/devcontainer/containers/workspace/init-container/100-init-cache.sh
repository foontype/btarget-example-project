#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_CACHE}" ]; then
    if [ ! -d ./run/devcontainer/.cache ]; then
        mkdir -p ./run/devcontainer/.cache
    fi

    ${SUDO} chown -R "${CONTAINER_USER}" ./run/devcontainer/.cache
fi
