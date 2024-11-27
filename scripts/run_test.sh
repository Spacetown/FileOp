#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

(
   pushd $THIS_DIRECTORY/../build

   echo "Run without no argument..."
   if ./FileOp.exe  2> stderr.log; then
      cat stderr.log | sed 's/^/   /'
      echo " -> Got unexpected exit code 0." 
      exit 1
   else
      cat stderr.log | sed 's/^/   /'
      echo " -> Got expected error."
   fi
   grep -F 'No command given. Use option --help.' stderr.log > /dev/null
   echo " -> Found expected output in log"

   echo "Run with option --help..."
   ./FileOp.exe --help | tee stdout.log | sed 's/^/   /'
   grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]' stdout.log > /dev/null
   echo " -> Found expected output in log"

   echo "Run with option -h and / instead of \..."
   cmd\.exe /Q /C "%cd:\=/%/FileOp.exe -h > stdout.log || exit 1"
   cat stdout.log | sed 's/^/   /'
   grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]' stdout.log > /dev/null
   echo " -> Found expected output in log"
   rm -f stdout.log
   
   echo "Run with command 'unknown'..."
   if ./FileOp.exe unknown 2> stderr.log ; then
      cat stderr.log | sed 's/^/   /'
      echo " -> Got unexpected exit code 0." 
      exit 1
   else
      cat stderr.log | sed 's/^/   /'
      echo " -> Got expected error."
   fi
   grep -F "Unknown command 'unknown' given, use option --help for more information." stderr.log > /dev/null
   echo " -> Found expected output in log"
   rm -f stderr.log
) || exit 1
