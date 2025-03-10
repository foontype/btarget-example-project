#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

source ../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}

task_down() {
    docker compose down
}

task_init() {
    # FIXME: write init code here.
    echo "there is nothing that needs to be init in the workspace."
    echo "see run/on-workspace/run.sh for more information."
}
