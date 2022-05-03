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
readonly DOTFILES_SRC_ROOT="$(cd ${CURRENT_ROOT}/..; pwd -P)"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly PREFERENCE_ROOT="${CURRENT_ROOT}/pref"
readonly AVAILABLE_ROOT="${CURRENT_ROOT}/available"
readonly AVAILABLE_APPS="${AVAILABLE_ROOT}/app"
readonly validate_config_link="${CURRENT_LIBRARY_SCRIPTS}/validate_config_link.sh"
${validate_config_link}
readonly get_config_link="${CURRENT_LIBRARY_SCRIPTS}/get_config_link.sh"
readonly CONFIG_LINK=$(${get_config_link})
readonly SYSTEM_PACKAGE_MANAGER_LINK="${CONFIG_LINK}/system-package-manager"
readonly AVAILABLE_SYSTEM_PACKAGE_MANAGER="${AVAILABLE_ROOT}/system-package-manager"
readonly AVAILABLE_SYSTEM_PACKAGE_MANAGER_LINK="${AVAILABLE_SYSTEM_PACKAGE_MANAGER}/link"
readonly AVAILABLE_SYSTEM_PACKAGE_MANAGER_PACKAGES="${AVAILABLE_SYSTEM_PACKAGE_MANAGER}/package"
readonly APPS_DIRECTORY="${CONFIG_LINK}/app"
readonly INITIALIZE_SCRIPT_NAME='initialize.sh'
readonly INSTALL_SCRIPT_NAME='install.sh'

readonly has_system_package_manager_key="${PREFERENCE_ROOT}/has-system-package-manager-key.sh"
readonly get_system_package_manager_packages_key="${PREFERENCE_ROOT}/get-system-package-manager-packages.sh"
readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make_relative_symlink.sh"

get_package_manager_name() {
    basename $(readlink "${1}")
}
readonly system_package_manager_name="$(get_package_manager_name "${SYSTEM_PACKAGE_MANAGER_LINK}")"

printf "Initializing system package manager (${system_package_manager_name}) .\n"
${SYSTEM_PACKAGE_MANAGER_LINK}/${INITIALIZE_SCRIPT_NAME}
${make_relative_symlink} "${AVAILABLE_APPS}/${system_package_manager_name}" "${APPS_DIRECTORY}/${system_package_manager_name}"
${make_relative_symlink} "${AVAILABLE_SYSTEM_PACKAGE_MANAGER_LINK}" "${AVAILABLE_APPS}/${system_package_manager_name}"

if $(${has_system_package_manager_key}); then
    printf 'Install packages which install with system package manager.\n'
    for package in $(${get_system_package_manager_packages_key}); do
        printf "Install ${package}...\n"
        ${APPS_DIRECTORY}/${package}/${INSTALL_SCRIPT_NAME} "${system_package_manager_name}"
        printf "Initialize ${package}...\n"
        ${APPS_DIRECTORY}/${package}/${INITIALIZE_SCRIPT_NAME}
        ${make_relative_symlink} "${AVAILABLE_APPS}/${package}" "${APPS_DIRECTORY}/${package}"
        ${make_relative_symlink} "${AVAILABLE_SYSTEM_PACKAGE_MANAGER_PACKAGES}/${package}" "${AVAILABLE_APPS}/${package}"
    done
fi

printf 'Finish initializing system package manager!\n'
