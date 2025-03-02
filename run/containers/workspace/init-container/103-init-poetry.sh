#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_POETRY}" -a -n "${INIT_CONTAINER_PYTHON}" ]; then
    : "${POETRY_PROJECT_PATH:?}"
    : "${POETRY_HOME:?}"

    cd "${POETRY_PROJECT_PATH}"
    poetry run python -m venv "${POETRY_PROJECT_PATH}/.venv"
    poetry install
fi
