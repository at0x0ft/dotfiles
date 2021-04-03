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
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly ZSH_PATH="$(cd ${SCRIPT_ROOT}/../zsh; pwd -P)"
readonly ZSHRC_PATH=$("${ZSH_PATH}/get-rc-path.sh")
readonly ZSHENV_PATH="${HOME}/.zshenv"
readonly ZINITRC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly ZCOMPDUMP_PATH="${HOME}/.zcompdump"
readonly ZINIT_PLUGINS_DIRECTIVE="source \"${SCRIPT_ROOT}/plugins.zsh\""
readonly ZINITRC_DIRECTIVE="source \"${ZINITRC_PATH}\""
readonly UBUNTU_SPECIFIC_DIRECTIVE='skip_global_compinit=1'

delete_directive_from() {
    local directive_lineno=$(grep -n "${1}" "${2}" | cut -d ':' -f 1)
    sed -i "${directive_lineno}d" "${2}" && [ ! -s "${2}" ] && rm -f "${2}"
    return 0
}

[ -f ${ZCOMPDUMP_PATH} ] && rm -f ${ZCOMPDUMP_PATH}

readonly get_os_type="${CURRENT_LIBRARY_SCRIPTS}/get-os-type.sh"
if [ "$(${get_os_type})" = 'Ubuntu' ]; then
    delete_directive_from "${UBUNTU_SPECIFIC_DIRECTIVE}" "${ZSHENV_PATH}"
fi

delete_directive_from "${ZINIT_PLUGINS_DIRECTIVE}" "${ZSHRC_PATH}"
delete_directive_from "${ZINITRC_DIRECTIVE}" "${ZSHRC_PATH}"
