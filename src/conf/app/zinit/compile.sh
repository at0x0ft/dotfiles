#!/usr/bin/env sh
set -e

readonly SCRIPT_PATH="$(
    self=${0}
    while [ -L "${self}" ]; do
        cd "${self%/*}"
        self=$(readlink "${self}")
    done
    cd "${self%/*}"
    echo "$(pwd -P)/${self##*/}"
)"
readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
readonly COMPILEDRC_PATH="${SCRIPT_ROOT}/compiled-module-rc.zsh"
readonly ZINITRC_PATH="${SCRIPT_ROOT}/rc.zsh"

zsh -i -c 'zinit module build; @zinit-scheduler burst || true'

sed -i -e "1s|^|source \"${COMPILEDRC_PATH}\"\n|" ${ZINITRC_PATH}
