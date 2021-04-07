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
readonly COMPILEDRC_PATH="${SCRIPT_ROOT}/compiled-module-rc.zsh"
readonly COMPILEDRC_DIRECTIVE="source '${COMPILEDRC_PATH}'"

readonly add_directive_to_zshrc_preload="${CURRENT_ROOT}/available/shell/link/rc/preload/add-directive.sh"

compile() {
    local login_zsh_shell="$("${CURRENT_LIBRARY_SCRIPTS}/get-login-shell.sh")"
    ${login_zsh_shell} -i -l -c 'zinit module build; @zinit-scheduler burst || true'
}
compile

${add_directive_to_zshrc_preload} "${COMPILEDRC_DIRECTIVE}"
