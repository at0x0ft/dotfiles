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
readonly PREFERENCE_ROOT="${CURRENT_ROOT}/pref"
${LIBRARY_SCRIPTS}/validate-config-link.sh
readonly CONFIG_LINK=$("${LIBRARY_SCRIPTS}/get-config-link.sh")
readonly SYSTEM_PACKAGE_MANAGER_LINK="${CONFIG_LINK}/system-package-manager"
readonly APPS_DIRECTORY="${CONFIG_LINK}/app"
readonly INITIALIZE_SCRIPT_NAME='initialize.sh'
readonly INSTALL_SCRIPT_NAME='install.sh'

readonly has_system_package_manager_key="${PREFERENCE_ROOT}/has-system-package-manager-key.sh"
readonly get_system_package_manager_packages_key="${PREFERENCE_ROOT}/get-system-package-manager-packages.sh"

printf 'Initializing system package manager.\n'
${SYSTEM_PACKAGE_MANAGER_LINK}/${INITIALIZE_SCRIPT_NAME}

if $(${has_system_package_manager_key}); then
    printf 'Install packages which install with system package manager.\n'
    for package in $(${get_system_package_manager_packages_key}); do
        printf "Install ${package}...\n"
        # resolve default package manager name and give to install script argument
        ${APPS_DIRECTORY}/${package}/${INSTALL_SCRIPT_NAME} 'default'
        printf "Initialize ${package}...\n"
        ${APPS_DIRECTORY}/${package}/${INITIALIZE_SCRIPT_NAME}
    done
fi

printf 'Finish initializing system package manager!\n'
