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
readonly EXEC_COMMAND="$(basename ${SCRIPT_ROOT})"

readonly current_login_shell="$(basename $("${CURRENT_LIBRARY_SCRIPTS}/get-login-shell.sh"))"
case ${current_login_shell} in
    "${EXEC_COMMAND}"* )
        :
        ;;
    * )
        echo "[Error] ${EXEC_COMMAND} is not the login shell." >&2
        echo "[Error] ${EXEC_COMMAND} cannot deploy." >&2
        exit 1
        ;;
esac
