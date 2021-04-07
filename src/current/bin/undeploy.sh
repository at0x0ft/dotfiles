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
readonly AVAILABLE_APPS="${CURRENT_ROOT}/available/app"
readonly UNDEPLOY_SCRIPT_NAME="undeploy.sh"

get_available_app_undeploy_scripts() {
    find "${AVAILABLE_APPS}" -follow -maxdepth 2 -name "${UNDEPLOY_SCRIPT_NAME}" -type f
}

printf 'Undeploying...\n'
for app_undeploy in $(get_available_app_undeploy_scripts); do
    app_name="$(basename $(dirname ${app_undeploy}))"
    printf "Undeploying ${app_name}...\n"
    ${app_undeploy}
done

printf 'Undeployment finished!\n'
