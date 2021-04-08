#!/usr/bin/env sh
set -e

if [ -f '/.dockerenv' ]; then
    printf true
else
    printf false
fi
