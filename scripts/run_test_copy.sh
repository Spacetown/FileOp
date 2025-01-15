#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

mkdir /tmp/$$

echo "copy a directory recursive..."
Timestamp=2000-01-01
if FileOp.exe --debug copy  --touch --time=$Timestamp --force --recursive --target-directory=/tmp/$$ "$(dirname ${BASH_SOURCE[0]})" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
for File in $(dirname ${BASH_SOURCE[0]})/*.* ; do
    File="/tmp/$$/scripts/$(basename $File)"
    echo -n "Check if ${File} exists..."
    if test -f $File ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
    echo -n "Check if timestamp is correct..."
    if test "$(stat --printf '%y' ${File})" = "$Timestamp 12:00:00.000000000 +0000" ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
done

echo "Set write protection to target files"
chmod -R oga-w /tmp/$$/scripts
ls -alR /tmp/$$

echo "copy a directory recursive to write protected target..."
Timestamp=2001-01-01
if FileOp.exe --debug copy --touch --force --time $Timestamp --recursive --target-directory /tmp/$$ "$(dirname ${BASH_SOURCE[0]})" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
for File in $(dirname ${BASH_SOURCE[0]})/*.* ; do
    File="/tmp/$$/scripts/$(basename $File)"
    echo -n "Check if ${File} exists..."
    if test -f $File ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
    echo -n "Check if timestamp is correct..."
    if test "$(stat --printf '%y' ${File})" = "$Timestamp 12:00:00.000000000 +0000" ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
done

echo "Set write protection to target files"
touch /tmp/$$/$(basename ${BASH_SOURCE[0]})
chmod -R oga-w /tmp/$$
ls -alR /tmp/$$

echo "copy a write protected file to a write protected target..."
Timestamp=2002-01-01
if FileOp.exe --debug copy --touch --force --time $Timestamp --target-directory /tmp/$$/scripts /tmp/$$/$(basename ${BASH_SOURCE[0]}) | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
File="/tmp/$$/scripts/$(basename ${BASH_SOURCE[0]})"
echo -n "Check if ${File} exists..."
if test -f $File ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
echo -n "Check if ${File} is writable..."
if test -w $File ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
echo -n "Check if timestamp is correct..."
if test "$(stat --printf '%y' ${File})" = "$Timestamp 12:00:00.000000000 +0000" ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
rm -rf /tmp/$$/*

echo "copy two files with same name to one directory..."
if FileOp.exe --debug copy --check-unique-names --target-directory /tmp/$$ ${BASH_SOURCE[0]} "$(dirname ${BASH_SOURCE[0]})/*.*" 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -F "FileOp.exe: error: File in source list will overwrite each other: $(basename ${BASH_SOURCE[0]})" stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log
File="/tmp/$$/$(basename ${BASH_SOURCE[0]})"
echo -n "Check if ${File} doesn't exists..."
if test -f $File ; then
    echo " failed."
    exit 1
else
    echo " ok."
fi
rm -rf /tmp/$$
