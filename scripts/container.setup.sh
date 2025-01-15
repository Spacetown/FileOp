#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y mingw-w64 cmake ninja-build python3 python3-pip python3-venv

python3 -m venv .venv
. ./.venv/bin/activate
pip install gcovr==8.2
