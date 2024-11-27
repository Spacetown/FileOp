#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Create temporary directory..."
FileOp.exe --debug mkdir $TEMP/$$
echo -n "Check if $TEMP/$$ exists..."
test -d $TEMP/$$ && ( echo " ok." ; exit 1 ) || ( echo " failed." && exit 0 )

echo "Create same directory again..."
( FileOp.exe mkdir $TEMP/$$ ) && ( echo "Got unexpected exit code 0." ; exit 1 ) || ( echo "Got expected error." && exit 0 )
echo "Create same directory again with option --parents..."
( FileOp.exe mkdir --parents $TEMP\\$$ ) && ( echo "Got unexpected exit code 0." ; exit 1 ) || ( echo "Got expected error." && exit 0 )
