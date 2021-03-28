#!/usr/bin/env sh
set -e

readonly SCRIPT_PATH=$(
    self=${0}
    while [ -L "${self}" ]; do
        cd "${self%/*}"
        self=$(readlink "${self}")
    done
    cd "${self%/*}"
    echo "$(pwd -P)/${self##*/}"
)
readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../.."; pwd -P)
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly ZSH_NAME='zsh'

readonly get_deployed_apps="${CURRENT_LIBRARY_SCRIPTS}/get-deployed-apps.sh"

zsh_is_deployed() {
    local result=false
    for deployed_app in $(${get_deployed_apps}); do
        if [ "$(basename ${deployed_app})" = "${ZSH_NAME}" ]; then
            result=true
            break
        fi
    done
    echo ${result}
}

if $(zsh_is_deployed); then
    echo true
else
    echo false
fi
