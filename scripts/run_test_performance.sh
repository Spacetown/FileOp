#!/usr/bin/env bash
set -e
set -o pipefail
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

export PATH=$THIS_DIRECTORY/../build:$PATH

max=100

rm -rf /tmp/$$
mkdir /tmp/$$
pushd /tmp/$$ > /dev/null

function append_rsp() {
   local current_dir=$1; shift
   local index=$1; shift

   if [ $index -le $max ] ; then
      echo "$current_dir " >> mkdir.rsp
      for i in $(seq 1 $max); do 
         echo "$current_dir/f$i " >> touch.rsp
      done
      append_rsp $current_dir/$index "$(($index + 1))"
   fi
}

echo """## Performance test

Creating lists for $max directories with with a depth of $max levels and $max files in each"""
time append_rsp root 0
echo """Lists contain $(wc --lines < mkdir.rsp) directories and $(wc --lines < touch.rsp) files.
Longest filename has $(wc --max-line-length < touch.rsp) characters.
"""

###############################################################################
echo """
### Using bash 

#### Creating directories"""
time xargs --max-chars=8000 --arg-file mkdir.rsp mkdir
echo "
#### Creating files"
time xargs --max-chars=8000 --arg-file touch.rsp touch
echo "
#### Removing tree"
time rm -rf root

###############################################################################
echo """
### Using FileOp

#### Creating directories"""
time xargs --max-chars=8000 --arg-file mkdir.rsp FileOp.exe mkdir
echo "
#### Creating files"
time xargs --max-chars=8000 --arg-file touch.rsp FileOp.exe touch
echo "
#### Removing tree"
time FileOp.exe remove --recursive --force root

###############################################################################
echo """
### Using FileOp with rsp 

#### Creating directories"""
time FileOp.exe mkdir @mkdir.rsp
echo "
#### Creating files"
time FileOp.exe touch @touch.rsp
echo "
#### Removing tree"
time FileOp.exe remove --recursive --force root
