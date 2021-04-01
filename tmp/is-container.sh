#!/usr/bin/env sh
set -e

if [ -f "/.dockerenv" ]; then
    echo true;
else
    echo false;
fi
