#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

(
   pushd $THIS_DIRECTORY/../build

   echo "Run without no argument..."
   if ./FileOp.exe  2> stderr.log; then
      cat stderr.log
      echo " -> Got unexpected exit code 0." 
      exit 1
   else
      cat stderr.log
      echo " -> Got expected error."
   fi
   grep -F 'No command given. Use option --help.' stderr.log > /dev/null
   
   echo "Run with option --help..."
   ./FileOp.exe --help | tee > stdout.log
   cat stdout.log
   grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]' stdout.log > /dev/null
   
   echo "Run with option -h and / instead of \..."
   cmd.exe /C "%cd:\=/%/FileOp.exe -h > stdout.log || exit 1"
   cat stdout.log
   grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]' stdout.log > /dev/null
   rm -f stdout.log
   
   echo "Run with command 'unknown'..."
   if cmd.exe /C "FileOp.exe unknown 2> stderr.log || exit 1"  ; then
      cat stderr.log
      echo " -> Got unexpected exit code 0." 
      exit 1
   else
      cat stderr.log
      echo " -> Got expected error."
   fi
   grep -F 'Unknown command [unknown] given, use option --help for more information.' stderr.log > /dev/null
   rm -f stderr.log
) || exit 1

$THIS_DIRECTORY/run_test_mkdir.sh
