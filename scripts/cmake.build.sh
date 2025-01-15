#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

pushd $THIS_DIRECTORY/../build
ninja --verbose
popd && exit $?