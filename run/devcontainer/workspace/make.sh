#!/usr/bin/env sh
set -e
cd $(dirname "${0}")
cat ./Dockerfile.base ../Dockerfile.workspace ./Dockerfile.user-workspace > ./Dockerfile
