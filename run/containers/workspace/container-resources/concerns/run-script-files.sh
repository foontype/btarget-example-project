#!/usr/bin/env bash

run_script_files() {
    local script_files=("$@")

    for f in ${script_files[@]}; do
        echo "${f}: start."
        bash ${f}
        echo "${f}: done."
    done
}