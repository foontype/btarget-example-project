#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

EXCLUDE_PATHS=(
    "./run/supports/bask/*"
    "./run/supports/btarget/*"
)

source ../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}

task_test() {
    cd ../..
    _bats_docker
}

_bats_docker() {
    docker run --rm -it \
        -v $(_os_path $(pwd)):/workspace \
        -w "/workspace" \
        -e "WORKSPACE_ROOT=/workspace" \
        bats/bats:1.11.1 \
        --print-output-on-failure \
        --pretty \
        --recursive \
        $(_list_bats_files)
}

_list_bats_files() {
    eval find . -type f -name "*.sh.bats" $(_exclude_paths)
}

_exclude_paths() {
    for p in "${EXCLUDE_PATHS[@]}"; do
        echo "-a -not -path \"${p}\""
    done
}

_os_path() {
    if [ "${OSTYPE}" == "cygwin" ]; then
        echo "$(cygpath -w "${1}")"
    else
        echo "${1}"
    fi
}
