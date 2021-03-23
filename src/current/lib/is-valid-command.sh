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
readonly EXEC_COMMAND="$(basename ${SCRIPT_ROOT})"

is_valid_command() {
    local login_shell="$("${CURRENT_LIBRARY_SCRIPTS}/get-login-shell.sh")"
    if [ ! "${1}" = '' ] && ${login_shell} -l -c "type ${1} > /dev/null 2>&1"; then
        echo true
    else
        echo false
    fi
}

is_valid_command "$@"
