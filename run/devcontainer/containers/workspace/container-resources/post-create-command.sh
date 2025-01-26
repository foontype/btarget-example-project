#!/usr/bin/env bash
cd $(dirname "${0}")

source ./concerns/run-script-files.sh

SCRIPT_FILES=(
    "./setup-local-terminal.sh"
)

run_script_files "${SCRIPT_FILES[@]}"
