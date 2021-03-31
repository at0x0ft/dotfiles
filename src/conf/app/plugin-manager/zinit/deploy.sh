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
readonly DOTFILES_SRC_ROOT="$(cd ${SCRIPT_ROOT}/../../..; pwd -P)"
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly ZSH_PATH="${SCRIPT_ROOT}/../zsh"
readonly ZSHRC_PATH=$("${ZSH_PATH}/get-rc-path.sh")
readonly ZSHENV_PATH="${HOME}/.zshenv"
readonly ZINITRC_TEMPLATE_PATH="${SCRIPT_ROOT}/rc.template.zsh"
readonly ZINITRC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly ZINIT_PLUGINS_DIRECTIVE="source \"${SCRIPT_ROOT}/plugins.zsh\""
readonly ZINITRC_DIRECTIVE="source \"${ZINITRC_PATH}\""
readonly UBUNTU_SPECIFIC_DIRECTIVE='skip_global_compinit=1'

printf '%s\n' "${ZINITRC_DIRECTIVE}" >> "${ZSHRC_PATH}"

readonly get_os_type="${CURRENT_LIBRARY_SCRIPTS}/get-os-type.sh"
if [ "$(${get_os_type})" = 'Ubuntu' ]; then
    printf '%s\n' "${UBUNTU_SPECIFIC_DIRECTIVE}" >> "${ZSHENV_PATH}"
fi
