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
readonly DEPLOY_SCRIPTS="${SCRIPT_ROOT}/deploy"
readonly DEPLOY_SCRIPT_NAME="deploy.sh"

get_available_app_deploy_scripts() {
    find "${AVAILABLE_APPS}" -follow -name "${DEPLOY_SCRIPT_NAME}" -type f
}

printf 'Deploying...\n'
for app_deploy in $(get_available_app_deploy_scripts); do
    app_name="$(basename $(dirname ${app_deploy}))"
    printf "Deploying ${app_name}...\n"
    ${app_deploy}
done

printf 'Deployment finished!\n'
