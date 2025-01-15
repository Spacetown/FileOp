#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

echo "Run help..."
FileOp.exe copy --help | sed 's/^/   stdout: /'

echo "Use unknown option..."
if FileOp.exe copy --xxx 2> stderr.log | sed 's/^/   stdout: /' ; then
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

echo "copy with missing argument..."
if FileOp.exe copy 2> stderr.log | sed 's/^/   stdout: /' ; then
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

mkdir --parent /tmp/$$
rm -rf /tmp/$$/*

echo "copy with missing source..."
if FileOp.exe copy /tmp/$$/file /tmp/$$/file2 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't copy file .+\\\\$$\\\\file to .+\\\\$$\\\\file2: The system cannot find the file specified." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "copy script file to other filename..."
TargetFile=/tmp/$$/target
if FileOp.exe copy "${BASH_SOURCE[0]}" ${TargetFile} | sed 's/^/   stdout: /' ; then
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

echo "copy script file to directory..."
TargetFile="/tmp/$$/$(basename "${BASH_SOURCE[0]}")"
if FileOp.exe --debug copy "${BASH_SOURCE[0]}" $(dirname ${TargetFile})/ | sed 's/^/   stdout: /' ; then
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

echo "copy script to existing target..."
if FileOp.exe copy "${BASH_SOURCE[0]}" ${TargetFile} 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi
grep -E "FileOp.exe: error: Can't copy file .+\\\\$(basename ${TargetFile}) to .+\\\\$$\\\\$(basename ${TargetFile}): The file exists." stderr.log > /dev/null
echo " -> Found expected output in log"
rm -f stderr.log

echo "copy script to existing target (forced)..."
TargetFile="/tmp/$$/$(basename "${BASH_SOURCE[0]}")"
if FileOp.exe --debug copy --force "${BASH_SOURCE[0]}" ${TargetFile} | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi

echo "copy script to existing target with option for target directory..."
TargetFile="/tmp/$$/$(basename "${BASH_SOURCE[0]}")"
if FileOp.exe --debug copy --target-directory=$(dirname ${TargetFile}) "${BASH_SOURCE[0]}" 2> stderr.log | sed 's/^/   stdout: /' ; then
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got unexpected exit code 0."
    exit 1
else
    cat stderr.log | sed 's/^/   stderr: /'
    echo " -> Got expected error."
fi

echo "copy script to existing target with option for target directory (forced)..."
TargetFile="/tmp/$$/$(basename "${BASH_SOURCE[0]}")"
if FileOp.exe --debug copy --force --target-directory=$(dirname ${TargetFile}) "${BASH_SOURCE[0]}" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
rm -f /tmp/$$/*.*

echo "copy a directory content with pattern..."
if FileOp.exe --debug copy --force --recursive --target-directory=/tmp/$$ "$(dirname ${BASH_SOURCE[0]})/*.*" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
for File in "$(dirname ${BASH_SOURCE[0]})/scripts/*.*"; do
    echo -n "Check if /tmp/$$/$(basename ${File}) exists..."
    if test -f /tmp/$$/$(basename ${File}) ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
done
rm -f /tmp/$$/*.*

echo "copy a directory..."
if FileOp.exe --debug copy --target-directory=/tmp/$$ "$(dirname ${BASH_SOURCE[0]})" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
for File in "$(dirname ${BASH_SOURCE[0]})/scripts/*.*"; do
    echo -n "Check if /tmp/$$/scripts/$(basename ${File}) doesn't exists..."
    if test -f /tmp/$$/scripts/$(basename ${File}) ; then
        echo " failed."
        exit 1
    else
        echo " ok."
    fi
done
rm -f /tmp/$$/scripts

echo "copy a directory recursive..."
if FileOp.exe --debug copy --force --recursive --target-directory=/tmp/$$ "$(dirname ${BASH_SOURCE[0]})" | sed 's/^/   stdout: /' ; then
    echo " -> Got expected exit code 0."
else
    echo " -> Got unexpected error."
    exit 1
fi
for File in "$(dirname ${BASH_SOURCE[0]})/scripts/*.*"; do
    echo -n "Check if /tmp/$$/scripts/$(basename ${File}) exists..."
    if test -f /tmp/$$/scripts/$(basename ${File}) ; then
        echo " ok."
    else
        echo " failed."
        exit 1
    fi
done
