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
readonly EXTERNAL_RC_PATH="${SCRIPT_ROOT}/external.zsh"
readonly COMPLETION_BASE_DIRECTIVE='zinit as "completion" \'
readonly INDENT='  '

if [ ! -s "${EXTERNAL_RC_PATH}" ]; then
    printf '%s\n' "${COMPLETION_BASE_DIRECTIVE}" > "${EXTERNAL_RC_PATH}"
fi

append_backslash_to_last_line() {
    local last_line="$(sed -n $(cat ${1} | grep -c '^')p ${1})"
    local converted="${last_line} "'\\'
    sed -i -e "s|^${last_line}$|${converted}|g" "${1}"
}
append_backslash_to_last_line "${EXTERNAL_RC_PATH}"

printf '%s\n' "${INDENT}${1}" >> "${EXTERNAL_RC_PATH}"
