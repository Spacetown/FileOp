#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "cat current script..."
if FileOp.exe cat "${BASH_SOURCE[0]}" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi

echo "cat file starting with --..."
echo "Test file" > --help.log
if FileOp.exe cat -- --help.log > stdout.log ; then
    cat stdout.log | sed 's/^/   stdout: /'
    echo " -> Got expected exit code 0."
else
    cat stdout.log | sed 's/^/   stdout: /'
    echo " -> Got unexpected error."
    exit 1
fi
grep -E "Test file" stdout.log > /dev/null
echo " -> Found expected output in log"
rm -f stdout.log

echo "cat a directory..."
if FileOp.exe cat $THIS_DIRECTORY 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Only files can be printed. Got directory [A-Z]:\\\\.*\\\\$(basename "$THIS_DIRECTORY")" stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

