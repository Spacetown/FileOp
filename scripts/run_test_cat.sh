#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Run help..."
FileOp.exe cat --help | sed 's/^/   /'

echo "Use unknown option..."
if FileOp.exe cat --xxx 2> stderr.log | sed 's/^/   /' ; then
    cat stderr.log | sed 's/^/   /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   /'
    echo " -> Got expected error."
fi
grep -F "Unknown option --xxx, use option --help for more information." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "cat with missing argument..."
if FileOp.exe cat 2> stderr.log | sed 's/^/   /' ; then
    cat stderr.log | sed 's/^/   /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   /'
    echo " -> Got expected error."
fi
grep -F "Too view arguments given." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "cat current script..."
if FileOp.exe cat "${BASH_SOURCE[0]}" | sed 's/^/   /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi

echo "cat file starting with --..."
echo "Test file" > --help.log
if FileOp.exe --debug cat -- --help.log > stdout.log ; then
    cat stdout.log | sed 's/^/   /'
    echo " -> Got expected exit code 0."
else
    cat stdout.log | sed 's/^/   /'
    echo " -> Got unexpected error."
    exit 1
fi
grep -E "Test file" stdout.log > /dev/null
echo " -> Found expected output in log"
rm -f stdout.log

echo "cat a directory..."
if FileOp.exe cat $THIS_DIRECTORY 2> stderr.log | sed 's/^/   /' ; then
    cat stderr.log | sed 's/^/   /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   /'
    echo " -> Got expected error."
fi
grep -E "Only files can be printed. Got directory [A-Z]:\\\\.*\\\\$(basename "$THIS_DIRECTORY")" stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

