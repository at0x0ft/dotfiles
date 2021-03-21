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

readonly is_valid_command="${CURRENT_LIBRARY_SCRIPTS}/is-valid-command.sh"

if ! $(${is_valid_command} ${EXEC_COMMAND}); then
    echo "[Error] Command (${exec_command}) is not executable." >&2
    echo "[Error] ${exec_command} cannot deploy." >&2
    exit 1
fi
