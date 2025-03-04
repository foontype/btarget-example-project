#!/usr/bin/env bash

if [ -n "${INIT_CONTAINER_PYTHON}" -a -n "${INIT_CONTAINER_UV}" ]; then
    echo ""
    echo "  PYTHON NOTE:"
    echo "  * uv init <name> to create a virtual environment into <name> directory."
    echo "  * use .venv/bin/python to run Python scripts."
    echo "  * In VSCode, 'Python: Select Interpreter' to select virtual environment."
    echo ""
fi
