#!/usr/bin/env bash

# Local terminal
if [ -n "${LOCAL_TERMINAL}" ]; then \
    REMOTE_COMMAND=$(basename "${LOCAL_TERMINAL}")
    REMOTE_COMMAND_PATH=$(which "${REMOTE_COMMAND}")
    LOCAL_COMMAND_PATH=$(dirname "${LOCAL_TERMINAL}")
    LOCAL_COMMAND_DIR=$(dirname "${LOCAL_COMMAND_PATH}")

    if [ ! "$(id -u):$(id -g)" = "0:0" ]; then
        SUDO="sudo"
    fi

    ${SUDO} mkdir -p "${LOCAL_COMMAND_DIR}"
    ${SUDO} bash -c "echo \"${REMOTE_COMMAND_PATH}\" > \"${LOCAL_COMMAND_PATH}\""
    ${SUDO} chmod 755 "${LOCAL_COMMAND_PATH}"

    mkdir -p /workspace/.vscode

    jq -n "{
        \"terminal.integrated.defaultProfile.linux\": \"${REMOTE_COMMAND}\",
        \"terminal.integrated.profiles.linux\": {
            \"${REMOTE_COMMAND}\": {
                \"path\": \"${LOCAL_COMMAND_PATH}\"
            }
        }
    }" | jq -s add /workspace/.vscode/settings.json - > /workspace/.vscode/settings.json.tmp

    mv /workspace/.vscode/settings.json.tmp /workspace/.vscode/settings.json

    echo ""
    echo "Local terminal is set to \"$(basename ${LOCAL_COMMAND_PATH})\"."
    echo "Reopen workspace to apply changes."
    echo ""
    echo "After reopen, \"Terminal: Create New Integrated Terminal (Local)\" in VSCode to open local terminal."
    echo ""

else
    if [ -f "/workspace/.vscode/settings.json" ]; then
        jq "del (.\"terminal.integrated.defaultProfile.linux\", \"terminal.integrated.profiles.linux\")" \
            /workspace/.vscode/settings.json > /workspace/.vscode/settings.json.tmp

        mv /workspace/.vscode/settings.json.tmp /workspace/.vscode/settings.json
    fi
fi
