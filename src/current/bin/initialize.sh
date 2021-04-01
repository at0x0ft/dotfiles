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

readonly get_preferred_package_manager="${PREFERENCE_PATH}/get-package-manager.sh"
readonly get_package_manager_config_path="${INITIALIZE_SCRIPTS}/get-package-manager-config-path.sh"
readonly initialize_package_manager="${INITIALIZE_SCRIPTS}/initialize-package-manager.sh"
readonly get_preferred_shell="${PREFERENCE_PATH}/get-shell.sh"
readonly get_shell_config_path="${INITIALIZE_SCRIPTS}/get-shell-config-path.sh"
readonly initialize_shell="${INITIALIZE_SCRIPTS}/initialize-shell.sh"
readonly get_preferred_plugin_manager="${PREFERENCE_PATH}/get-plugin-manager.sh"
readonly get_plugin_manager_config_path="${INITIALIZE_SCRIPTS}/get-plugin-manager-config-path.sh"
readonly initialize_plugin_manager="${INITIALIZE_SCRIPTS}/initialize-plugin-manager.sh"

extract_pair_first() {
    printf "${1}"
}

extract_pair_second() {
    printf "${2}"
}

printf 'Initializing...\n'

# Initialize default package-manager

readonly package_manager_pair="$(${get_preferred_package_manager})"
readonly package_manager=$(extract_pair_first ${package_manager_pair})
readonly package_manager_init_method=$(extract_pair_second ${package_manager_pair})
printf "Preferred package manager: ${package_manager}\n"
readonly package_manager_path="$(${get_package_manager_config_path} "${package_manager}")"
printf 'Initializing...\n'
${initialize_package_manager} "${package_manager_path}" "${package_manager_init_method}"

readonly shell_pair="$(${get_preferred_shell})"
readonly shell=$(extract_pair_first ${shell_pair})
readonly shell_init_method=$(extract_pair_second ${shell_pair})
printf "Preferred shell: ${shell}\n"
readonly shell_path="$(${get_shell_config_path} "${shell}")"
printf 'Initializing...\n'
${initialize_shell} "${shell_path}" "${shell_init_method}"

readonly plugin_manager_pair="$(${get_preferred_plugin_manager})"
readonly plugin_manager=$(extract_pair_first ${plugin_manager_pair})
readonly plugin_manager_init_method=$(extract_pair_second ${plugin_manager_pair})
printf "Preferred plugin manager: ${plugin_manager}\n"
readonly plugin_manager_path="$(${get_plugin_manager_config_path} "${plugin_manager}")"
printf 'Initializing...\n'
${initialize_plugin_manager} "${plugin_manager_path}" "${plugin_manager_init_method}"
exit 1

for package in $(enumarate_)

printf 'Initializing finished!\n'
