#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

(
   pushd $THIS_DIRECTORY/../build

   echo "Run without no argument..."
   if ./FileOp.exe ; then
      echo " -> Got unexpected exit code 0." 
      exit 1
   else
      echo " -> Got expected error."
   fi
   
   echo "Run with option --help..."
   ./FileOp.exe --help | tee > stdout.log
   cat stdout.log
   grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]' stdout.log > /dev/null
   
   echo "Run with option -h and / instead of \..."
   cmd.exe /C "./FileOp.exe -h" | tee > stdout.log
   cat stdout.log
   grep -F 'FileOp.exe [<options>] [<command> [<options>] <argument+>]' stdout.log > /dev/null

   echo "Run with command 'unknown'..."
   if cmd.exe /C "FileOp.exe unknown " 2> stderr.log ; then
      cat stderr.log
      echo " -> Got unexpected exit code 0." 
      exit 1
   else
      cat stderr.log
      echo " -> Got expected error."
   fi
   grep -F 'Unknown command [unknown] given, use option --help for more information.' stderr.log > /dev/null
) || exit 1

$THIS_DIRECTORY/run_test_mkdir.sh
