#!/usr/bin/env sh
set -e
cd $(dirname "${0}")
mkdir -p ../../.cache
cat ./Dockerfile.base ../../Dockerfile.workspace ./Dockerfile.user-workspace > ../../.cache/Dockerfile
