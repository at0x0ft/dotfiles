#!/usr/bin/env sh
set -e

readonly WSL_FEATURE_PATH='/proc/sys/fs/binfmt_misc/WSLInterop'

if [ -f ${WSL_FEATURE_PATH} ]; then
    echo true;
else
    echo false;
fi
