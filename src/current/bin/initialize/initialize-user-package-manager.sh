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
${CURRENT_LIBRARY_SCRIPTS}/validate-config-link.sh
readonly CONFIG_LINK=$("${CURRENT_LIBRARY_SCRIPTS}/get-config-link.sh")
readonly PACKAGE_MANAGER_DIRECTORY="${CONFIG_LINK}/package-manager"
readonly AVAILABLE_USER_PACKAGE_MANAGER="${AVAILABLE_ROOT}/user-package-manager"
readonly AVAILABLE_USER_PACKAGE_MANAGER_LINK="${AVAILABLE_USER_PACKAGE_MANAGER}/link"
readonly AVAILABLE_USER_PACKAGE_MANAGER_PACKAGES="${AVAILABLE_USER_PACKAGE_MANAGER}/package"
readonly APPS_DIRECTORY="${CONFIG_LINK}/app"
readonly INITIALIZE_SCRIPT_NAME='initialize.sh'
readonly INSTALL_SCRIPT_NAME='install.sh'

readonly has_user_package_manager_key="${PREFERENCE_ROOT}/has-user-package-manager-key.sh"
readonly get_user_package_manager="${PREFERENCE_ROOT}/get-user-package-manager.sh"
readonly has_user_package_manager_package_key="${PREFERENCE_ROOT}/has-user-package-manager-package-key.sh"
readonly get_user_package_manager_packages="${PREFERENCE_ROOT}/get-user-package-manager-packages.sh"
readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make-relative-symlink.sh"

if ! $(${has_user_package_manager_key}); then
    exit 0
fi

printf 'Initializing user package manager.\n'

readonly user_package_manager=$(${get_user_package_manager})
printf "Install ${user_package_manager}...\n"
${PACKAGE_MANAGER_DIRECTORY}/${user_package_manager}/${INSTALL_SCRIPT_NAME}
printf "Initialize ${user_package_manager}...\n"
${PACKAGE_MANAGER_DIRECTORY}/${user_package_manager}/${INITIALIZE_SCRIPT_NAME}
${make_relative_symlink} "${AVAILABLE_APPS}/${user_package_manager}" "${APPS_DIRECTORY}/${user_package_manager}"
${make_relative_symlink} "${AVAILABLE_USER_PACKAGE_MANAGER_LINK}" "${AVAILABLE_APPS}/${user_package_manager}"

if $(${has_user_package_manager_package_key}); then
    printf 'Install packages which install with user package manager.\n'
    for package in $(${get_user_package_manager_packages}); do
        printf "Install ${package}...\n"
        ${APPS_DIRECTORY}/${package}/${INSTALL_SCRIPT_NAME} "${user_package_manager}"
        printf "Initialize ${package}...\n"
        ${APPS_DIRECTORY}/${package}/${INITIALIZE_SCRIPT_NAME}
        ${make_relative_symlink} "${AVAILABLE_APPS}/${package}" "${APPS_DIRECTORY}/${package}"
        ${make_relative_symlink} "${AVAILABLE_USER_PACKAGE_MANAGER_PACKAGES}/${package}" "${AVAILABLE_APPS}/${package}"
    done
fi

printf 'Finish initializing user package manager!\n'
