#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Run help..."
FileOp.exe remove --help | sed 's/^/   stdout: /'

echo "Use unknown option..."
if FileOp.exe remove --xxx 2> stderr.log | sed 's/^/   stdout: /' ; then
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

echo "remove with missing argument..."
if FileOp.exe remove 2> stderr.log | sed 's/^/   stdout: /' ; then
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

echo "remove a single file..."
touch /tmp/$$
if FileOp.exe --debug remove /tmp/$$ | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
echo -n "Check if /tmp/$$ is removed..."
if test -f /tmp/$$ ; then
    echo " failed."
    exit 1
else
    echo " ok."
fi
echo "remove a non existing file..."
if FileOp.exe --debug remove --recursive /tmp/$$ 2>&1 > stdout.log | sed 's/^/x   /' ; then
    cat stdout.log | sed 's/^/   stdout: /'
    echo " -> Got expected exit code 0."
else
    cat stdout.log | sed 's/^/   stdout: /'
    echo " -> Got unexpected error."
    exit 1
fi
grep -E "Skip .+\\\\$$ because it doesn't exist." stdout.log > /dev/null
echo " -> Found expected output in log"
rm -f stdout.log

echo "create directory structure..."
mkdir --parents /tmp/$$/test/subdir /tmp/$$/junction_target
echo "Junction target file content" > /tmp/$$/junction_target/test_file
touch /tmp/$$/test/subdir/test_file_1
touch /tmp/$$/test/subdir/test_file_2_readonly
touch /tmp/$$/test/subdir/test_file_3
attrib +R /tmp/$$/test/subdir/test_file_2_readonly
pushd /tmp/$$/test/subdir
# Need to escape the /, else it's converted by msys to C:\
cmd.exe //c "mklink /J junction ..\\..\\junction_target"
cat junction/test_file
popd
ls -alR /tmp/$$

echo "remove not empty directory..."
if FileOp.exe remove /tmp/$$/test 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't remove directory .+\\\\$$\\\\test: The directory is not empty." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log
for file in test_file_1 test_file_2_readonly test_file_3 junction/test_file ; do
    echo -n "Check if /tmp/$$/test/subdir/$file still exists..."
    if test -f /tmp/$$/test/subdir/$file ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
done

echo "remove recursive not empty directory..."
if FileOp.exe --debug remove --recursive /tmp/$$/test 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't remove file .+\\\\$$\\\\test\\\\subdir\\\\test_file_2_readonly: Access is denied." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log
for file in test_file_1 junction/test_file ; do
    echo -n "Check if /tmp/$$/test/subdir/$file is removed..."
    if test -f /tmp/$$/test/subdir/$file ; then
        echo " failed."
        exit 1
    else
        echo " ok."
    fi
done
for file in ../../junction_target/test_file test_file_2_readonly test_file_3 ; do
    echo -n "Check if /tmp/$$/test/subdir/$file still exists..."
    if test -f /tmp/$$/test/subdir/$file ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
done

echo "remove forced recursive not empty directory..."
if FileOp.exe remove --recursive --force /tmp/$$/test | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
echo -n "Check if /tmp/$$/test is removed..."
if test -d /tmp/$$/test ; then
    echo " failed."
    exit 1
else
    echo " ok."
fi
rm -rf /tmp/$$

mkdir -- --$$
echo "Remove file --$$..."
FileOp.exe --debug remove -- --$$ | sed 's/^/   stdout: /'
echo -n "Check if --$$ is removed..."
if test -f --$$ ; then
    echo " failed."
    exit 1
else
    echo " ok."
fi
