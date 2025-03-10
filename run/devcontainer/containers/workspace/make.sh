#!/usr/bin/env sh
set -e
cd $(dirname "${0}")
mkdir -p ../../.caches
cat ./Dockerfile.base ../../Dockerfile.workspace ./Dockerfile.user-workspace > ../../.caches/Dockerfile
