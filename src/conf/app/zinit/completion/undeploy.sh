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
readonly DOTFILES_SRC_ROOT="$(cd ${SCRIPT_ROOT}/../../../..; pwd -P)"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly GENERAL_PATH="${SCRIPT_ROOT}/general.zsh"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"
readonly GENERAL_DIRECTIVE="source '${GENERAL_PATH}'"
readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"

readonly delete_line="${LIBRARY_SCRIPTS}/delete-line.sh"

${delete_line} "${EXTERNAL_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${GENERAL_DIRECTIVE}" "${RC_PATH}"
if [ ! -s "${RC_PATH}" ]; then
    rm "${RC_PATH}"
fi

if [ -f "${EXTERNAL_PATH}" ] && [ ! -s "${EXTERNAL_PATH}" ]; then
    rm "${EXTERNAL_PATH}"
fi
