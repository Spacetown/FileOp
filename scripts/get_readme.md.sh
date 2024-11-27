#!/usr/bin/env bash
set -e
THIS_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"

GitCommitSha=$(git rev-parse HEAD)
GitRemoteUrl=$(git remote get-url origin | sed -e "s|\.git|/tree/${GitCommitSha}|")

cat ${THIS_DIRECTORY}/../README.md
echo """

## Build infos

Build from commit [${GitCommitSha}](${GitRemoteUrl})
"""
