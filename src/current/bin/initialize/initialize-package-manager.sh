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
readonly CURRENT_ROOT="$(cd ${SCRIPT_ROOT}/../..; pwd -P)"
readonly INITIALIZED_APPS_PATH="${CURRENT_ROOT}/app-state/initialized"
readonly INITIALIZE_SCRIPT_NAME="initialize.sh"
readonly INITIALIZED_PACKAGE_MANAGER_LINKNAME="package-manager"

readonly register_initialized_package_manager="${INITIALIZED_APPS_PATH}/register.sh"

# considier can-initialize validation
# if ! $(${1}/${can_deploy_script}); then
#     echo "[Error] App ($(basename ${1})) cannot deploy." >&2
#     exit 1
# fi

# echo "path = ${1}, method = ${2}"
${1}/${INITIALIZE_SCRIPT_NAME} "${2}"

${register_initialized_package_manager} "${INITIALIZED_PACKAGE_MANAGER_LINKNAME}" "${1}"
