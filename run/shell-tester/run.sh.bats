#!/usr/bin/env bats

setup() {
    source() {
        [ "$(basename "${1}")" = "bask.sh" ] && return
        command source "${@}"
    }

    source "${WORKSPACE_ROOT}/run/shell-tester/run.sh"
}

@test "EXCLUDE_PATHS" {
    local expect_paths="./run/supports/bask/* ./run/supports/btarget/*"

    [ "$(echo ${EXCLUDE_PATHS[@]})" = "${expect_paths}" ]
}
