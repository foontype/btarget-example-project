#!/usr/bin/env bash
cd $(dirname "${0}")

# Use sudo if the container user is root
export SUDO=""
if [ "${CONTAINER_USER}" = "0:0" ]; then
    export SUDO="sudo"
fi

# Run all init scripts
script_files=(ls ./[0-9]*)
for f in ${script_files[@]}; do
  if [[ -f "$f" ]]; then
      echo "${f}: start."
      bash "$f"
      echo "${f}: done."
  fi
done
