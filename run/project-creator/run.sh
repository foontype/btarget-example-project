#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

EXPORT_OPTIONS="--exclude=\"README.md\""
EXPORT_OPTIONS="${EXPORT_OPTIONS} --exclude=\"run/project-creator\""
EXPORT_OPTIONS="${EXPORT_OPTIONS} --exclude=\"run/supports/*\""

source ../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks
}

task_create() {
    local new_project_name="${NEW_PROJECT_NAME:?}"
    local new_project_base_dir="${NEW_PROJECT_BASE_DIR:-../../..}"
    local new_project_export_path="$(cd "${new_project_base_dir}" && pwd)/${new_project_name}"
    local template_source_path="../.."

    echo "creating new project \"${new_project_name}\" (${new_project_export_path}) ..."

    mkdir -p "${new_project_export_path}"

    _export_project "${template_source_path}" "${new_project_export_path}"
    _init_git "${new_project_export_path}"
    _init_project_submodules "${new_project_export_path}"
    #_replace_project_name "${new_project_export_path}" "${new_project_name}"

    echo "done."
}

task_submodules() {
    echo "submodules:"
    _list_submodules

    echo ""
    echo "submodule urls:"
    for s in $(_list_submodules); do
        echo "${s} => $(_get_submodule_url "${s}")"
    done
}

_export_project() {
    local source_path="${1}"
    local export_path="${2}"

    (cd "${source_path}" && git archive --format=tar HEAD) \
        | tar -xvf - -C "${export_path}" ${EXPORT_OPTIONS}
}

_init_git() {
    local export_path="${1}"

    (
        cd "${export_path}"
        git init
    )
}
 
_init_project_submodules() {
    local export_path="${1}"

    for s in $(_list_submodules); do
        local submodule_url=$(_get_submodule_url "${s}")

        (
            cd "${export_path}"
            _init_submodule "${s}" "${submodule_url}"
        )
    done
}

_replace_project_name() {
    local export_path="${1}"
    local project_name="${1}"

    (
        cd ${export_path}
        find . -type f -print0 \
            | xargs -0 sed -i "s/btarget-example-project/${project_name}/g"
    )
}

_init_submodule() {
    local submodule_path="${1}"
    local submodule_url="${2}"

    git submodule deinit -f "${submodule_path}"
    git rm -f "${submodule_path}"
    rm -rf ".git/modules/${submodule_path}"
    rmdir "${submodule_path}"

    git submodule add "${submodule_url}" "${submodule_path}"
}

_list_submodules() {
    for p in $(git submodule foreach --quiet 'echo $name'); do
        echo "${p}"
    done
}

_get_submodule_url() {
    local submodule_path="${1}"

    git config --file ../../.gitmodules submodule."$submodule_path".url
}
