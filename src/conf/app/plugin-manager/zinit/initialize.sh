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

# install zinit

# enumerate and register apps which manage with zinit

# initialize (install) registered apps
initialize_registered_apps() {
    local login_zsh_shell="$("${CURRENT_LIBRARY_SCRIPTS}/get-login-shell.sh")"
    ${login_zsh_shell} -i -l
}
initialize_registered_apps
