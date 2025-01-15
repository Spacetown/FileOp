#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

rm -rf /tmp/$$

echo "touch temporary file..."
Timestamp=2000-01-01T12:30
for equal_or_not in ' ' '=' ; do
    FileOp.exe --debug touch --time$equal_or_not$Timestamp /tmp/$$ | sed 's/^/   stdout: /'
    echo -n "Check if /tmp/$$ exists..."
    if test -f /tmp/$$ ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
    echo -n "Check if timestamp is correct..."
    if test "$(stat --printf '%y' /tmp/$$)" = "${Timestamp/T/ }:00.000000000 +0000" ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
    rm -f /tmp/$$
done

echo "touch file --$$..."
FileOp.exe touch -- --$$ | sed 's/^/   stdout: /'
echo -n "Check if --$$ exists..."
if test -f --$$ ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
rm -rf -- --$$

echo "touch file with DOS device prefix..."
FileOp.exe touch //?/$(cmd.exe //c "echo %TEMP%/$$") | sed 's/^/   stdout: /'
echo -n "Check if /tmp/$$ exists..."
if test -f /tmp/$$ ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
rm -rf $$

echo "touch file //$COMPUTERNAME/my_share/test..."
if FileOp.exe --debug touch //$COMPUTERNAME/my_share/test 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -F "FileOp.exe: error: Can't get handle to UNC\\$COMPUTERNAME\\my_share\\test: The network name cannot be found." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log
