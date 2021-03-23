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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly ZSH_PATH="$(cd "${SCRIPT_ROOT}/../zsh"; pwd -P)"
readonly ZSHRC_PATH="$("${ZSH_PATH}/get-rc-path.sh")"
readonly COMPILEDRC_PATH="${SCRIPT_ROOT}/compiled-module-rc.zsh"
readonly COMPILEDRC_DIRECTIVE="source \"${COMPILEDRC_PATH}\""

compile() {
    local login_zsh_shell="$("${CURRENT_LIBRARY_SCRIPTS}/get-login-shell.sh")"
    ${login_zsh_shell} -i -l -c 'zinit module build; @zinit-scheduler burst || true'
}

compile

sed -i -e "1s|^|source \"${COMPILEDRC_PATH}\"\n|" ${ZSHRC_PATH}
