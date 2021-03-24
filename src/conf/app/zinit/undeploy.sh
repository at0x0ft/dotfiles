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
readonly DOTFILES_SRC_ROOT="$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)"
readonly ZSH_PATH="$(cd ${SCRIPT_ROOT}/../zsh; pwd -P)"
readonly ZSHRC_PATH=$("${ZSH_PATH}/get-rc-path.sh")
readonly ZINITRC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly ZCOMPDUMP_PATH="${HOME}/.zcompdump"
readonly ZINIT_PLUGINS_DIRECTIVE="source \"${SCRIPT_ROOT}/plugins.zsh\""
readonly ZINITRC_DIRECTIVE="source \"${ZINITRC_PATH}\""

delete_directive_from_rcfile() {
    local directive_lineno=$(grep -n "${1}" "${ZSHRC_PATH}" | cut -d ':' -f 1)
    sed -i "${directive_lineno}d" "${ZSHRC_PATH}" && [ ! -s "${ZSHRC_PATH}" ] && rm -f "${ZSHRC_PATH}"
    return 0
}

[ -f ${ZCOMPDUMP_PATH} ] && rm -f ${ZCOMPDUMP_PATH}

delete_directive_from_rcfile "${ZINIT_PLUGINS_DIRECTIVE}"
delete_directive_from_rcfile "${ZINITRC_DIRECTIVE}"
