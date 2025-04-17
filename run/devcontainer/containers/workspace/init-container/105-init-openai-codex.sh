#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_OPENAI_CODEX}" ]; then
    : "${CODEX_CONFIG:?}"

    if [ -d "${CODEX_CONFIG}" ]; then
        exit
    fi

    ${SUDO} mkdir -p "${CODEX_CONFIG}"
    ${SUDO} chmod 755 "${CODEX_CONFIG}"
fi
