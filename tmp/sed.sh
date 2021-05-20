#!/usr/bin/env sh
set -e

# Usage: ./extra-regex.sh pattern
# ${1} = pattern: regex pattern string
# calling example: echo 'aaabbbccc' | ./extra-regex.sh 's/aaa(BBB|bbb)ccc/aaaccc/g'

is_gnu() {
    if command sed --version 2>&1 | grep -q GNU; [ "${?}" -eq 0 ]; then
        printf true
    else
        printf false
    fi
}

exregex() {
    if $(is_gnu); then
        printf "${1}" | sed -r "${2}"
    else
        printf "${1}" | sed -E "${2}"
    fi
}

exregex $(grep -e '^NAME=' /etc/os-release) 's/^NAME="(.*)"$/\1/'
