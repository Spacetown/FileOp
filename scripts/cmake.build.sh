#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

cmake --build $THIS_DIRECTORY/../src/../build --verbose