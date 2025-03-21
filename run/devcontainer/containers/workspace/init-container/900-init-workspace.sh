#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_WORKSPACE}" ]; then
    RUN_TARGET_SELECT=devcontainer bash /workspace/run/target.sh init
fi
