#!/usr/bin/env sh
set -e

if [ "$(uname)" = "Darwin" ]; then
    dscl . -read "/Users/${USER}" UserShell | sed -E 's/^.*: (.*)$/\1/'
else
    printf "$(grep "$(whoami)" /etc/passwd | cut -d: -f7)"
fi
