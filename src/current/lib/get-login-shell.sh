#!/usr/bin/env sh
set -e

printf "$(grep "$(whoami)" /etc/passwd | cut -d: -f7)"
