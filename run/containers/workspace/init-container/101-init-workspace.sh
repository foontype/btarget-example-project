#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_WORKSPACE}" ]; then
    bash /workspace/run/target.sh setup
fi
