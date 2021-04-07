#!/usr/bin/env sh
set -e

readonly SCRIPT_PATH=$(
    self=${0}
    while [ -L "${self}" ]; do
        cd "${self%/*}"
        self=$(readlink "${self}")
    done
    cd "${self%/*}"
    echo "$(pwd -P)/${self##*/}"
)
readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
readonly RC_PATH="${SCRIPT_ROOT}/rc.vim"
readonly VIMRC_PATH="${HOME}/.vimrc"

ln -snvf "${RC_PATH}" "${VIMRC_PATH}"
