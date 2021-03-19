#!/usr/bin/env sh
set -e

grep -e '^NAME=' /etc/os-release | sed -r 's/^NAME="(.*)"$/\1/' | tr [:upper:] [:lower:]
