#!/usr/bin/env bash
set -e
cd $(dirname "${0}")

NEW_PROJECT_NAME="${NEW_PROJECT_NAME:?}"
NEW_PROJECT_PATH="$(cd "../../.." && pwd)/${NEW_PROJECT_NAME}"
TEMPLATE_PROJECT_PATH="$(cd "../.." && pwd)"

EXPORT_OPTIONS="--exclude=README.md"
EXPORT_OPTIONS="${EXPORT_OPTIONS} --exclude=run/project-creator"
EXPORT_OPTIONS="${EXPORT_OPTIONS} --exclude=run/project-creator/*"

REPLACE_FIND_OPTIONS="-not -path \"*/.git/*\""
REPLACE_FIND_OPTIONS="${REPLACE_FIND_OPTIONS} -a -not -path \"*/run/supports/*\""

source ../supports/bask/src/bask.sh

bask_default_task="usage"

task_usage() {
    bask_list_tasks

    echo ""
    echo "usage:"
    echo "  run 'create' task to create new project in '${NEW_PROJECT_PATH}'."

    echo ""
    echo "submodules (these will be setup in new project):"
    _show_submodules

    echo ""
    echo "configurations:"
    echo "  * NEW_PROJECT_NAME=${NEW_PROJECT_NAME}"
    echo "  * NEW_PROJECT_PATH=${NEW_PROJECT_PATH}"
    echo "  * TEMPLATE_PROJECT_PATH=${TEMPLATE_PROJECT_PATH}"
    echo ""
}

task_create() {
    echo "creating new project \"${NEW_PROJECT_NAME}\" (${NEW_PROJECT_PATH}) ..."

    bask_sequence \
        setup_project_dir \
        setup_project_files \
        setup_project_git \
        setup_project_submodules \
        setup_project_contents

    echo "done."
}

task_setup_project_dir() {
    mkdir -p "${NEW_PROJECT_PATH}"
}

task_setup_project_files() {
    _export_project "${TEMPLATE_PROJECT_PATH}" "${NEW_PROJECT_PATH}"
}

task_setup_project_git() {
    _init_git "${NEW_PROJECT_PATH}"
}

task_setup_project_submodules() {
    _init_submodules "${NEW_PROJECT_PATH}"
}

task_setup_project_contents() {
    _replace_contents "${NEW_PROJECT_PATH}" "${NEW_PROJECT_NAME}"
}

_export_project() {
    local template_project_path="${1}"
    local project_path="${2}"

    (cd "${template_project_path}" && git archive --format=tar HEAD) \
        | tar ${EXPORT_OPTIONS} -xvf - -C "${project_path}"
}

_init_git() {
    local project_path="${1}"

    (
        cd "${project_path}"
        git init
    )
}

_init_submodules() {
    local project_path="${1}"

    for s in $(_list_submodules); do
        local submodule_url=$(_get_submodule_url "${s}")

        _init_submodule "${project_path}" "${s}" "${submodule_url}"
    done
}

_init_submodule() {
    local project_path="${1}"
    local submodule_path="${2}"
    local submodule_url="${3}"

    (
        cd "${project_path}"

        git submodule deinit -f "${submodule_path}"
        git rm -f "${submodule_path}"
        rm -rf ".git/modules/${submodule_path}"
        rmdir "${submodule_path}"

        git submodule add "${submodule_url}" "${submodule_path}"
    )
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

_show_submodules() {
    for s in $(_list_submodules); do
        echo "  * ${s} => $(_get_submodule_url "${s}")"
    done
}

_replace_contents() {
    local project_path="${1}"
    local project_name="${2}"

    (
        cd "${project_path}"
        for f in $(eval find . -type f ${REPLACE_FIND_OPTIONS}); do
            echo "replacing in ${f} ..."
            _replace_file "s/btarget-example-project/${project_name}/g" "${f}"
        done
    )
}

_replace_file() {
    local pattern="${1}"
    local file="${2}"

    case "${OSTYPE}" in
    darwin*)
        sed -i '' "${pattern}" "${file}"
        ;;
    *)
        sed -i "${pattern}" "${file}"
        ;;
    esac
}