#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Create temporary directory..."
FileOp.exe --debug mkdir $TEMP/$$ | sed 's/^/   /'
echo -n "Check if $TEMP/$$ exists..."
if test -d $TEMP/$$ ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi

echo "Create same directory again..."
if FileOp.exe mkdir $TEMP/$$ 2> stderr.log | sed 's/^/   /' ; then
    cat stderr.log | sed 's/^/   /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Directory \\[[A-Z]:\\\\.+\\\\$$\\] already exists." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "Create same directory again with option --parents..."
if FileOp.exe mkdir --parents $TEMP\\$$ ; then
    echo "Got expected exit code 0."
else
    echo "Got unexpected error."
fi

