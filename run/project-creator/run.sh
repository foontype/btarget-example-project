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
        local new_project_base_dir="${NEW_PROJECT_BASE_DIR:-../../..}"
        local new_project_export_path="$(cd "${new_project_base_dir}" && pwd)/${new_project_name}"
        local template_export_path="../.."

        echo "creating new project \"${new_project_name}\" (${new_project_export_path}) ..."

        mkdir -p "${new_project_export_path}"

        (cd "${template_export_path}" && git archive --format=tar HEAD) \
                        | tar -xvf - -C "${new_project_export_path}" \
                                --exclude="README.md" \
                                --exclude="run/project-creator" \
                                --exclude="run/supports/*"

        (
                cd "${new_project_export_path}" 
                git init

                git submodule deinit -f run/supports/bask
                git rm -f run/supports/bask
                rm -rf .git/modules/run/supports/bask

                git submodule deinit -f run/supports/btarget
                git rm -f run/supports/btarget
                rm -rf .git/modules/run/supports/btarget

                git submodule add https://github.com/jez/bask.git run/supports/bask
                git submodule add https://github.com/foontype/btarget.git run/supports/btarget

                find . -type f -print0 \
                        | xargs -0 sed -i "s/btarget-example-project/${new_project_name}/g"
        )

        echo "done."
}
