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
readonly EXTERNAL_RC_PATH="${SCRIPT_ROOT}/external.zsh"
readonly COMPLETION_BASE_DIRECTIVE='zinit as "completion" \'
readonly INDENT='  '

readonly delete_line="${LIBRARY_SCRIPTS}/delete-line.sh"

${delete_line} "${1}" "${EXTERNAL_RC_PATH}"

delete_backslash_from_last_line() {
    local last_line="$(sed -n $(cat ${1} | grep -c '^')p ${1})"
    local last_content="${last_line% \\}"
    sed -i -e "s|^${last_content}"' \\'"$|${last_content}|g" "${1}"
}
delete_backslash_from_last_line "${EXTERNAL_RC_PATH}"

[ $(cat "${EXTERNAL_RC_PATH}" | grep -c '^') -eq 1 ] && ${delete_line} "${COMPILEDRC_DIRECTIVE}" "${EXTERNAL_RC_PATH}"
