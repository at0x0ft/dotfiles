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
readonly ZSH_PATH="$(cd ${SCRIPT_ROOT}/../zsh; pwd -P)"
readonly ZSHRC_PATH="$("${ZSH_PATH}/get-rc-path.sh")"
readonly COMPILEDRC_DIRECTIVE="source \"${COMPILEDRC_PATH}\""
readonly ZCOMPDUMP_PATH="${HOME}/.zcompdump"
readonly ZSH_COMPILED_EXT='.zwc'
readonly ZCOMPDUMP_COMPILED_PATH="${HOME}/.zcompdump${ZSH_COMPILED_EXT}"

readonly directive_lineno=$(grep -n "${COMPILEDRC_DIRECTIVE}" "${ZSHRC_PATH}" | cut -d ':' -f 1)
sed -i "${directive_lineno}d" "${ZSHRC_PATH}" && [ ! -s "${ZSHRC_PATH}" ] && rm -f "${ZSHRC_PATH}"

[ -f ${ZCOMPDUMP_PATH} ] && rm -f ${ZCOMPDUMP_PATH}
[ -f ${ZCOMPDUMP_COMPILED_PATH} ] && rm -f ${ZCOMPDUMP_COMPILED_PATH}

for compiled_file in $(find . -name "*${ZSH_COMPILED_EXT}" -type f); do
    rm -f ${compiled_file}
done
