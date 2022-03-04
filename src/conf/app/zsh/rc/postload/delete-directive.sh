#!/usr/bin/env sh
set -ex

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
readonly DOTFILES_SRC_ROOT="$(cd ${SCRIPT_ROOT}/../../../../..; pwd -P)"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"

readonly delete_line="${LIBRARY_SCRIPTS}/delete-line.sh"

${delete_line} "${1}" "${RC_PATH}"
if [ ! -s "${RC_PATH}" ]; then
    rm "${RC_PATH}"
fi
