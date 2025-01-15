#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Run help..."
FileOp.exe touch --help | sed 's/^/   stdout: /'

echo "Use unknown option..."
if FileOp.exe touch --xxx 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -F "FileOp.exe: error: Unknown option --xxx, use option --help for more information." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "touch with missing argument..."
if FileOp.exe touch 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -F "FileOp.exe: error: Too view arguments given." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "touch with missing time..."
if FileOp.exe touch --time 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -F "FileOp.exe: error: Option --time needs an argument" stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "touch temporary file..."
Timestamp=2000-01-01
for equal_or_not in ' ' '=' ; do
    cmd.exe //c "FileOp.exe --debug touch --time$equal_or_not$Timestamp //?/%TEMP%/$$" | sed 's/^/   stdout: /'
    echo -n "Check if /tmp/$$ exists..."
    if test -f /tmp/$$ ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
    echo -n "Check if timestamp is correct..."
    if test "$(stat --printf '%y' /tmp/$$)" = "$Timestamp 12:00:00.000000000 +0000" ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
    rm -f /tmp/$$
done

echo "touch file --$$..."
FileOp.exe --debug touch -- --$$ | sed 's/^/   stdout: /'
echo -n "Check if --$$ exists..."
if test -f --$$ ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
