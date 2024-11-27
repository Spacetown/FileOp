#!/usr/bin/env bash
set -ex
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo -n "Run without an argument..."
( FileOp.exe 2> /dev/null ) && ( echo " got unexpected exit code 0." ; exit 1 ) || ( echo " got expected error." && exit 0 )

echo "Run with option --debug and --help..."
FileOp.exe --debug --help | grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]'
echo "Run with option -d and -h and / instead of \..."
cmd.exe /C "$THIS_DIRECTORY/../build/FileOp.exe -h" | grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]'

echo "Run with option -h and / instead of \..."
cmd.exe /C "$THIS_DIRECTORY/../build/FileOp.exe -d -h"

echo "Run with option -h and / instead of \..."
cmd.exe /C "$THIS_DIRECTORY/../build/FileOp.exe -d -h" | grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]'

echo -n "Run with unknown command..."
{ FileOp.exe unknown 2>&1 1>&3 | grep -F 'Unknown command [unknown] given, use option --help for more information.'  } 3>&1

$THIS_DIRECTORY/run_test_mkdir.sh
