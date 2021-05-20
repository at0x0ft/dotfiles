#!/usr/bin/env sh
set -e

if [ "$(uname)" = "Darwin" ]; then
    uname
else
    grep -e '^NAME=' /etc/os-release | sed -r 's/^NAME="(.*)"$/\1/'
fi
