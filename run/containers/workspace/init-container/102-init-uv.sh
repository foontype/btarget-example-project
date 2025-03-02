#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_UV}" ]; then
    : "${UV_INSTALL_DIR:?}"

    if [ -d "${UV_INSTALL_DIR}" ]; then
        exit
    fi

    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
