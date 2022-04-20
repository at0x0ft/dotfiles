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
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"
readonly COMPLETION_BASE_DIRECTIVE='zinit as "completion" \'
readonly INDENT='  '

readonly init_external="${SCRIPT_ROOT}/init-external.sh"

if [ ! -s "${EXTERNAL_PATH}" ]; then
    printf "${COMPLETION_BASE_DIRECTIVE}\n" > "${EXTERNAL_PATH}"
fi

append_backslash_to_last_line() {
    local last_line="$(sed -n $(cat ${1} | grep -c '^')p ${1})"
    local converted="${last_line} "'\\'
    cat "${1}" | (rm "${1}" && sed -e "s|^${last_line}$|${converted}|g" > "${1}")
}
append_backslash_to_last_line "${EXTERNAL_PATH}"

printf "${INDENT}${1}\n" >> "${EXTERNAL_PATH}"
