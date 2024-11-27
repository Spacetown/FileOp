#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

set -x

echo -n "Run without an argument..."
( FileOp.exe 2> /dev/null ) && ( echo " got unexpected exit code 0." ; exit 1 ) || ( echo " got expected error." && exit 0 )

echo "Run with option --help..."
FileOp.exe --help | grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]'

$THIS_DIRECTORY/run_test_mkdir.sh
