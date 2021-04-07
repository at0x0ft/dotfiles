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
readonly DOTFILES_SRC_ROOT="$(cd ${SCRIPT_ROOT}/../../../../..; pwd -P)"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"

readonly delete_line="${LIBRARY_SCRIPTS}/delete-line.sh"

${delete_line} "${1}" "${EXTERNAL_PATH}"
if [ ! -s "${EXTERNAL_PATH}" ]; then
    rm "${EXTERNAL_PATH}"
fi
