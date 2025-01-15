#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

rm -rf /tmp/$$
mkdir /tmp/$$

echo "move with missing target..."
if FileOp.exe move /tmp/$$/file 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Too view arguments given." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "move with missing source..."
if FileOp.exe move /tmp/$$/file /tmp/$$/file2 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't move file .+\\\\$$\\\\file to .+\\\\$$\\\\file2: The system cannot find the file specified." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

mkdir -p /tmp/$$

echo "move with missing target directory I..."
if FileOp.exe move --target-directory= /tmp/$$/file2 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Target directory must not be empty." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "move with missing target directory II..."
if FileOp.exe move --target-directory 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Option --target-directory needs an argument." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "move filefile to non existing directory..."
mkdir -p /tmp/$$
cp -f ${BASH_SOURCE[0]} ${BASH_SOURCE[0]}.tmp
if FileOp.exe move ${BASH_SOURCE[0]}.tmp /tmp/$$/test/ 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Directory .+\\\\test doesn't exist." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "move file starting starting with --..."
echo "Test" > "--source"
if FileOp.exe move -- --source --target | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
echo -n "Check if --source doesn't exists..."
if test -f --source ; then
    echo " failed."
    exit 1
else
    echo " ok."
fi
echo -n "Check if --target exists..."
if test -f --target ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi
rm -rf -- --target

echo "move file to directory..."
cp -f ${BASH_SOURCE[0]} ${BASH_SOURCE[0]}.tmp
TargetFile="/tmp/$$/$(basename "${BASH_SOURCE[0]}").tmp"
if FileOp.exe --debug move "${BASH_SOURCE[0]}.tmp" $(dirname ${TargetFile})/ | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
echo -n "Check if ${TargetFile} exists..."
if test -f ${TargetFile} ; then
    echo " ok."
else
    echo " failed."
    exit 1
fi

echo "move directory to existing file..."
cp -f ${BASH_SOURCE[0]} ${BASH_SOURCE[0]}.tmp
if FileOp.exe move --target-directory ${TargetFile} "${BASH_SOURCE[0]}.tmp"  2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Target .+\\\\$(basename ${TargetFile}) must be a directory." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "move file to existing target..."
cp -f ${BASH_SOURCE[0]} ${BASH_SOURCE[0]}.tmp
if FileOp.exe --debug move "${BASH_SOURCE[0]}.tmp" ${TargetFile} 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't move file .+\\\\$(basename ${TargetFile}) to .+\\\\$$\\\\$(basename ${TargetFile}): The file exists." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "move file to existing write protected target (forced)..."
cp -f ${BASH_SOURCE[0]} ${BASH_SOURCE[0]}.tmp
TargetFile="/tmp/$$/$(basename "${BASH_SOURCE[0]}").tmp"
chmod ogu-w ${TargetFile}
if FileOp.exe --debug move --force "${BASH_SOURCE[0]}.tmp" ${TargetFile} | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi

echo "move file to existing target with option for target directory..."
cp -f ${BASH_SOURCE[0]} ${BASH_SOURCE[0]}.tmp
TargetFile="/tmp/$$/$(basename "${BASH_SOURCE[0]}").tmp"
if FileOp.exe --debug move --target-directory=$(dirname ${TargetFile}) "${BASH_SOURCE[0]}.tmp" 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi

echo "move file to existing target with option for target directory (forced)..."
cp -f ${BASH_SOURCE[0]} ${BASH_SOURCE[0]}.tmp
TargetFile="/tmp/$$/$(basename "${BASH_SOURCE[0]}").tmp"
chmod oga-r ${TargetFile}
if FileOp.exe --debug move --force --target-directory=$(dirname ${TargetFile}) "${BASH_SOURCE[0]}.tmp" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi

echo "move two files with same name to one directory..."
if FileOp.exe --debug move --check-unique-names --target-directory /tmp/$$ ${BASH_SOURCE[0]} "$(dirname ${BASH_SOURCE[0]})/*.*" 2> stderr.log | sed 's/^/   stdout: /' ; then
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

echo "move a directory content with pattern..."
mkdir /tmp/$$/source
cp -rf $(dirname ${BASH_SOURCE[0]})/*.* /tmp/$$/source/
if cmd.exe //c "FileOp.exe --debug copy --force --recursive --target-directory=%TEMP%/$$ %TEMP%/$$/source/*.*" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
for File in $(dirname ${BASH_SOURCE[0]})/*.* ; do
    File="/tmp/$$/$(basename $File)"
    echo -n "Check if ${File} exists..."
    if test -f $File ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
done
rm -f /tmp/$$/*.*

echo "move a file list..."
Timestamp=2001-01-01
cp -rf $(dirname ${BASH_SOURCE[0]})/*.* /tmp/$$/source/
if FileOp.exe --debug move --force --touch --time=$Timestamp /tmp/$$/source/*.* /tmp/$$ | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
for File in $(dirname ${BASH_SOURCE[0]})/*.* ; do
    File="/tmp/$$/source/$(basename $File)"
    echo -n "Check if ${File} doesn't exists..."
    if test -f $File ; then
        echo " failed."
        exit 1
    else
        echo " ok."
    fi
    File="/tmp/$$/$(basename $File)"
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
rm -rf /tmp/$$/*.*

echo "Set write protection to target files"
mkdir -p /tmp/$$/source
cp -rf $(dirname ${BASH_SOURCE[0]}) /tmp/$$/source/
cp -rf $(dirname ${BASH_SOURCE[0]}) /tmp/$$/
chmod -R oga-w /tmp/$$/*
ls -alR /tmp/$$

echo "move a directory to write protected target..."
Timestamp=2002-01-01
if FileOp.exe --debug move --force --touch --time $Timestamp --target-directory /tmp/$$ /tmp/$$/source/scripts | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
for File in $(dirname ${BASH_SOURCE[0]})/*.* ; do
    File="/tmp/$$/source/scripts/$(basename $File)"
    echo -n "Check if ${File} doesn't exists..."
    if test -f $File ; then
        echo " failed."
        exit 1
    else
        echo " ok."
    fi
    File="/tmp/$$/scripts/$(basename $File)"
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
done

