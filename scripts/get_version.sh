#!/usr/bin/env bash

set -e

THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

CurrentTag="$(sed --silent -e '/^## / { s/^## //; p }' $THIS_DIRECTORY/../Changelog.md \
    | head --lines 1 \
    | sed --silent -e '/^[0-9]*\.[0-9]*\.[0-9]*/ p')"
if [ -z "${CurrentTag}" ] ; then
    CurrentTag="0.0.0"
fi
echo "${CurrentTag}"