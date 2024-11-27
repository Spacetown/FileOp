#!/usr/bin/env bash

THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

cmake --build $THIS_DIRECTORY/../src/../build --verbose