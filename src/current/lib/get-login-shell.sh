#!/usr/bin/env sh
set -e

printf '%s' "$(grep "$(whoami)" /etc/passwd | cut -d: -f7)"
