#!/usr/bin/env sh
set -eu

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
readonly LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"

readonly DEPLOYED_DIR=$("${LIBRARY_SCRIPTS}/get-deployed-directory.sh")
readonly DEPLOYED_PACKAGE_MANAGER_LINK="${DEPLOYED_DIR}/package-manager"
readonly DEPLOYED_SHELL_LINK="${DEPLOYED_DIR}/shell"

readonly get_deployed_apps="${LIBRARY_SCRIPTS}/get-deployed-apps.sh"

is_normal_app() {
    local app_name="$(basename ${1})"
    local deployed_package_manager_name="$(basename $(readlink ${DEPLOYED_PACKAGE_MANAGER_LINK}))"
    local deployed_shell_name="$(basename $(readlink ${DEPLOYED_SHELL_LINK}))"
    if [ ! "${deployed_package_manager_name}" = "${app_name}" -a ! "${deployed_shell_name}" = "${app_name}" ]; then
        echo true
    else
        echo false
    fi
}

for deployed_app in $(${get_deployed_apps}); do
    if $(is_normal_app ${deployed_app}); then
        echo "${deployed_app}"
    fi
done
