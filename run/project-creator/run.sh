#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

source ../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
        bask_list_tasks
}

task_create() {
        local new_project_name="${NEW_PROJECT_NAME:?}"
        local new_project_export_dir="${NEW_PROJECT_EXPORT_DIR:-../../..}"
        local new_project_dir="${new_project_export_dir}/${new_project_name}"
        local export_path="../.."

        echo "creating new project \"${new_project_name}\" (${new_project_dir}) ..."

        mkdir -p "${project_dir}"
        (cd "${export_path}" && git archive --format=tar HEAD) \
                | tar -xvf - -C "${new_project_dir}"

        echo "done."
}