#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Create temporary directory..."
FileOp.exe --debug mkdir $TEMP/$$
echo -n "Check if $TEMP/$$ exists..."
if test -d $TEMP/$$ ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi

echo "Create same directory again..."
if FileOp.exe mkdir $TEMP/$$ ; then
    echo " -> Got unexpected exit code 0."
    exit 1
else
    echo " -> Got expected error."
fi

echo "Create same directory again with option --parents..."
if FileOp.exe mkdir --parents $TEMP\\$$
    echo "Got expected exit code 0."
else
    echo "Got unexpected error."
fi

