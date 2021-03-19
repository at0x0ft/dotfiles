#!/usr/bin/env sh
set -e

if [ ! "${1}" = '' ] && type ${1} > /dev/null 2>&1; then
    echo true
else
    echo false
fi
