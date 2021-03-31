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
readonly ZSH_PATH="${SCRIPT_ROOT}/../zsh"
readonly ZSHRC_PATH=$("${ZSH_PATH}/get-rc-path.sh")
readonly P10KRC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly P10KRC_DIRECTIVE="source \"${P10KRC_PATH}\""
readonly INSTANT_PROMPT_PATH="${SCRIPT_ROOT}/instant-prompt.zsh"
readonly INSTANT_PROMPT_DIRECTIVE="source \"${INSTANT_PROMPT_PATH}\""

delete_directive_from_zshrc() {
    local directive_lineno=$(grep -n "${1}" "${ZSHRC_PATH}" | cut -d ':' -f 1)
    sed -i "${directive_lineno}d" "${ZSHRC_PATH}" && [ ! -s "${ZSHRC_PATH}" ] && rm -f "${ZSHRC_PATH}"
    return 0
}

delete_directive_from_zshrc "${INSTANT_PROMPT_DIRECTIVE}"
delete_directive_from_zshrc "${P10KRC_DIRECTIVE}"
