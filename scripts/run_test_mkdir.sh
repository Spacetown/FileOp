#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

rm -rf /tmp/$$

echo "mkdir temporary directory..."
FileOp.exe --debug mkdir /tmp/$$ | sed 's/^/   stdout: /'
echo -n "Check if /tmp/$$ exists..."
if test -d /tmp/$$ ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi

echo "mkdir same directory again..."
if FileOp.exe mkdir /tmp/$$ 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Directory [A-Z]:\\\\.+\\\\$$ already exists\\." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "mkdir same directory again with option --parents..."
if FileOp.exe mkdir --parents /tmp/$$ ; then
    echo "Got expected exit code 0."
else
    echo "Got unexpected error."
fi

echo "mkdir directory structure..."
if FileOp.exe mkdir /tmp/$$/a/b/c 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't create directory [A-Z]:\\\\.*\\\\$$\\\\a\\\\b\\\\c: The system cannot find the path specified\\." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "mkdir directory structure with option --parents..."
if FileOp.exe mkdir --parents /tmp/$$/a/b/c ; then
    echo "Got expected exit code 0."
else
    echo "Got unexpected error."
fi
echo -n "Check if /tmp/$$/a/b/c exists..."
if test -d /tmp/$$/a/b/c ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi

echo "mkdir directory starting with --..."
if FileOp.exe mkdir -- --help | sed 's/^/   stdout: /'; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
if test -d '--help' ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi

echo "Use a existing file..."
if FileOp.exe mkdir "${BASH_SOURCE[0]}" 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Not a directory [A-Z]:\\\\.*\\\\$(basename "${BASH_SOURCE[0]}")\\." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log


echo "Use illegal characters..."
if FileOp.exe --debug mkdir --parents "/tmp/$$/test/invalid_|_name/test" 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't create directory [A-Z]:\\\\.*\\\\test\\\\invalid_|_name\\\\test_:" stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo -n "Check if /tmp/$$/test exists..."
if test -d /tmp/$$/test ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
