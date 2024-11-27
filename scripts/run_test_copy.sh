#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Run help..."
FileOp.exe copy --help | sed 's/^/   /'

echo "Use unknown option..."
if FileOp.exe copy --xxx 2> stderr.log | sed 's/^/   /' ; then
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

echo "copy with missing argument..."
if FileOp.exe copy 2> stderr.log | sed 's/^/   /' ; then
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

