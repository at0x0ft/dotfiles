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

printf '%s\n' "${P10KRC_DIRECTIVE}" >> "${ZSHRC_PATH}"
sed -i -e "1s|^|${INSTANT_PROMPT_DIRECTIVE}\n|" ${ZSHRC_PATH}
