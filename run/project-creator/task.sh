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

UPDATE_PATHS="run/containers/workspace"
UPDATE_PATHS="${UPDATE_PATHS} run/devcontainer/.env.example"
UPDATE_PATHS="${UPDATE_PATHS} run/devcontainer/.env.example.cygwin"
UPDATE_PATHS="${UPDATE_PATHS} run/devcontainer/.env.example.mac"
UPDATE_PATHS="${UPDATE_PATHS} run/devcontainer/.env.example.wsl"
UPDATE_PATHS="${UPDATE_PATHS} .devcontainer/devcontainer.json"
UPDATE_PATHS="${UPDATE_PATHS} .gitignore"

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
    _replace_project_contents "${NEW_PROJECT_PATH}" "${NEW_PROJECT_NAME}"
}

task_diff() {
    for f in ${UPDATE_PATHS}; do
        _diff_content "${TEMPLATE_PROJECT_PATH}" "${NEW_PROJECT_PATH}" "${f}"
    done
}

task_update() {
    local go="${GO:-}"

    for f in ${UPDATE_PATHS}; do
        _update_content "${TEMPLATE_PROJECT_PATH}" "${NEW_PROJECT_PATH}" "${f}" "${go}"
    done

    if [ "${go}" = "go" ]; then
        echo "done."
    else
        echo "'GO=\"go\" NEW_PROJECT_NAME=\"${NEW_PROJECT_NAME}\" ${0} update' will actually update files."
    fi
}

task_import() {
    local go="${GO:-}"

    for f in ${UPDATE_PATHS}; do
        _update_content "${NEW_PROJECT_PATH}" "${TARGET_PROJECT_PATH}" "${f}" "${go}"
    done

    if [ "${go}" = "go" ]; then
        echo "done."
    else
        echo "'GO=\"go\" NEW_PROJECT_NAME=\"${NEW_PROJECT_NAME}\" ${0} update' will actually import files."
    fi
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

_replace_project_contents() {
    local project_path="${1}"
    local project_name="${2}"

    _replace_dir_contents "${project_path}" "${project_name}"
}

_replace_dir_contents() {
    local dir="${1}"
    local project_name="${2}"

    (
        cd "${dir}"
        for f in $(eval find . -type f ${REPLACE_FIND_OPTIONS}); do
            echo "replacing in ${f} ..."
            _replace_file_contents "${f}" "${project_name}"
        done
    )
}

_replace_file_contents() {
    local file="${1}"
    local project_name="${2}"

    _replace_content "s/btarget-example-project/${project_name}/g" "${file}"
}

_replace_content() {
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

_diff_content() {
    local source_project_path="${1}"
    local target_project_path="${2}"
    local path="${3}"

    (
        local source_path="${source_project_path}/${path}"
        local target_path="${target_project_path}/${path}"
        local action_type="$(_file_type "${source_path}")$(_file_type "${target_path}")"

        echo "${action_type} \"${source_path}\" -> \"${target_path}\""

        case "${action_type}" in
        FF) diff -u "${target_path}" "${source_path}";;
        DD) diff -ur "${target_path}" "${source_path}";;
        esac
    )
}

_update_content() {
    local source_project_path="${1}"
    local target_project_path="${2}"
    local path="${3}"
    local go="${4}"

    (
        local source_path="${source_project_path}/${path}"
        local target_path="${target_project_path}/${path}"
        local action_type="$(_file_type "${source_path}")$(_file_type "${target_path}")"

        echo "${action_type} \"${source_path}\" -> \"${target_path}\""

        if [ "${go}" = "go" ]; then
            case "${action_type}" in
            [FDX][FD])
                if [ -e "${target_path}" ]; then
                    rm -rf "${target_path}"
                fi
                ;;
            esac

            case "${action_type}" in
            F[FX])
                cp "${source_path}" "${target_path}"
                _replace_file_contents "${target_path}" "${NEW_PROJECT_NAME}"
                ;;
            D[DX])
                cp -r "${source_path}" "${target_path}"
                _replace_dir_contents "${target_path}" "${NEW_PROJECT_NAME}"
                ;;
            esac
        fi
    )
}

_file_type() {
    local path="${1}"

    if [ -f "${path}" ]; then
        echo "F"
    elif [ -d "${path}" ]; then
        echo "D"
    else
        echo "X"
    fi
}
