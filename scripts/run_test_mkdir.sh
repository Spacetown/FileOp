#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Run help..."
FileOp.exe mkdir --help | sed 's/^/   /'

echo "Use unknown option..."
if FileOp.exe mkdir --xxx 2> stderr.log | sed 's/^/   /' ; then
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

echo "Mkdir with missing argument..."
if FileOp.exe mkdir 2> stderr.log | sed 's/^/   /' ; then
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

echo "mkdir temporary directory..."
FileOp.exe --debug mkdir $TEMP/$$ | sed 's/^/   /'
echo -n "Check if $TEMP/$$ exists..."
if test -d $TEMP/$$ ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi

echo "mkdir same directory again..."
if FileOp.exe mkdir $TEMP/$$ 2> stderr.log | sed 's/^/   /' ; then
    cat stderr.log | sed 's/^/   /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Directory [A-Z]:\\\\.+\\\\$$ already exists." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "mkdir same directory again with option --parents..."
if FileOp.exe mkdir --parents $TEMP/$$ ; then
    echo "Got expected exit code 0."
else
    echo "Got unexpected error."
fi

echo "mkdir directory structure..."
if FileOp.exe mkdir $TEMP/$$/a/b/c 2> stderr.log | sed 's/^/   /' ; then
    cat stderr.log | sed 's/^/   /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't mkdir directory [A-Z]:\\\\.*\\\\$$\\\\a\\\\b\\\\c." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "mkdir directory structure with option --parents..."
if FileOp.exe mkdir --parents $TEMP/$$/a/b/c ; then
    echo "Got expected exit code 0."
else
    echo "Got unexpected error."
fi
echo -n "Check if $TEMP/$$/a/b/c exists..."
if test -d $TEMP/$$/a/b/c ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi

echo "mkdir directory starting with --..."
if FileOp.exe --debug mkdir -- --help | sed 's/^/   /'; then
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
if FileOp.exe mkdir "${BASH_SOURCE[0]}" 2> stderr.log | sed 's/^/   /' ; then
    cat stderr.log | sed 's/^/   /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Not a directory [A-Z]:\\\\.*\\\\$(basename "${BASH_SOURCE[0]}")." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log


echo "Use illegal characters..."
if FileOp.exe --debug mkdir --parents "$TEMP/$$/test/invalid_|_name/test" 2> stderr.log | sed 's/^/   /' ; then
    cat stderr.log | sed 's/^/   /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't mkdir directory [A-Z]:\\\\.*\\\\test\\\\invalid_|_name\\\\test:" stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo -n "Check if $TEMP/$$/test exists..."
if test -d $TEMP/$$/test ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
