#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

cmake --fresh -G Ninja "$@" -S $THIS_DIRECTORY/../src -B $THIS_DIRECTORY/../build --toolchain $THIS_DIRECTORY/../src/mingw64.toolchain
