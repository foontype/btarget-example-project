#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_CLAUDE_CODE}" ]; then
    : "${CLAUDE_CONFIG_DIR:?}"

    if [ -d "${CLAUDE_CONFIG_DIR}" ]; then
        exit
    fi

    ${SUDO} mkdir -p "${CLAUDE_CONFIG_DIR}"
    ${SUDO} chmod 755 "${CLAUDE_CONFIG_DIR}"
fi
