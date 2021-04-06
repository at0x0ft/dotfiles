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
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../.."; pwd -P)
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"

readonly is_valid_command="${SCRIPT_ROOT}/is-valid-command.sh"

get_command_path() {
    local login_shell="$("${CURRENT_LIBRARY_SCRIPTS}/get-login-shell.sh")"
    ${login_shell} -l -c "which ${1}"
}

if ! $(${is_valid_command} "${1}"); then
    return 1
fi
get_command_path "$@"
