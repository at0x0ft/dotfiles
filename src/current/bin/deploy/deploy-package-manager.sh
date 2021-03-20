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
readonly LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly DEPLOYED_DIR="$(${LIBRARY_SCRIPTS}/get-deployed-directory.sh)"
readonly DEPLOYED_APPS="${DEPLOYED_DIR}/app"
readonly DEPLOYED_PACKAGE_MANAGER_LINK="${DEPLOYED_DIR}/package-manager"

readonly deploy_app="${SCRIPT_ROOT}/deploy-app.sh"

${deploy_app} ${1}

readonly deployed_app_link="${DEPLOYED_APPS}/$(basename ${1})"
${make_relative_symlink} ${DEPLOYED_PACKAGE_MANAGER_LINK} ${deployed_app_link}
