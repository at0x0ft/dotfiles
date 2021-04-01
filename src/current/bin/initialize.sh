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
readonly PREFERENCE_PATH="${CURRENT_ROOT}/pref"
readonly INITIALIZE_SCRIPTS="${SCRIPT_ROOT}/initialize"
readonly INITIALIZE_METHOD_ARG='-w'

readonly get_preferred_package_manager="${PREFERENCE_PATH}/get-package-manager.sh"
readonly get_package_manager_config_path="${INITIALIZE_SCRIPTS}/get-package-manager-config-path.sh"
readonly initialize_package_manager="${INITIALIZE_SCRIPTS}/initialize-package-manager.sh"
readonly get_preferred_shell="${PREFERENCE_PATH}/get-shell.sh"
readonly get_shell_config_path="${INITIALIZE_SCRIPTS}/get-shell-config-path.sh"
readonly initialize_shell="${INITIALIZE_SCRIPTS}/initialize-shell.sh"
readonly get_preferred_plugin_manager="${PREFERENCE_PATH}/get-plugin-manager.sh"
readonly get_plugin_manager_config_path="${INITIALIZE_SCRIPTS}/get-plugin-manager-config-path.sh"
readonly initialize_plugin_manager="${INITIALIZE_SCRIPTS}/initialize-plugin-manager.sh"

printf 'Initializing...\n'

# Initialize default package-manager

readonly preferred_package_manager="$(${get_preferred_package_manager})"
printf "Preferred package manager: ${preferred_package_manager}\n"
readonly package_manager_path="$(${get_package_manager_config_path} "${preferred_package_manager}")"
printf 'Initializing...\n'
readonly package_manager_init_method="$(${get_preferred_package_manager} ${INITIALIZE_METHOD_ARG})"
${initialize_package_manager} "${package_manager_path}" "${package_manager_init_method}"

readonly preferred_shell="$(${get_preferred_shell})"
printf "Preferred shell: ${preferred_shell}\n"
readonly shell_path="$(${get_shell_config_path} "${preferred_shell}")"
printf 'Initializing...\n'
readonly shell_init_method="$(${get_preferred_shell} ${INITIALIZE_METHOD_ARG})"
${initialize_shell} "${shell_path}" "${shell_init_method}"

readonly preferred_plugin_manager="$(${get_preferred_plugin_manager})"
printf "Preferred plugin manager: ${preferred_plugin_manager}\n"
readonly plugin_manager_path="$(${get_plugin_manager_config_path} "${preferred_plugin_manager}")"
printf 'Initializing...\n'
readonly plugin_manager_init_method="$(${get_preferred_plugin_manager} ${INITIALIZE_METHOD_ARG})"
${initialize_package_manager} "${plugin_manager_path}" "${plugin_manager_init_method}"

exit 1

printf 'Initializing finished!\n'
