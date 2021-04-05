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
readonly CURRENT_ROOT="$(cd ${SCRIPT_ROOT}/..; pwd -P)"
readonly INITIALIZE_SCRIPTS="${SCRIPT_ROOT}/initialize"

readonly initialize_system_package_manager="${INITIALIZE_SCRIPTS}/initialize-system-package-manager.sh"
readonly initialize_user_package_manager="${INITIALIZE_SCRIPTS}/initialize-user-package-manager.sh"
readonly initialize_shell="${INITIALIZE_SCRIPTS}/initialize-shell.sh"

printf 'Initializing...\n'

${initialize_system_package_manager}
${initialize_user_package_manager}
${initialize_shell}

printf 'Initializing finished!\n'
