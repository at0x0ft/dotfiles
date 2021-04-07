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
readonly SHELL_DIRECTORY="${CONFIG_LINK}/shell"
readonly SYSTEM_LOGIN_SHELL_LINK="${CONFIG_LINK}/system-login-shell"
readonly AVAILABLE_SHELL="${AVAILABLE_ROOT}/shell"
readonly AVAILABLE_SHELL_LINK="${AVAILABLE_SHELL}/link"
readonly AVAILABLE_SHELL_PLUGIN_MANAGER_LINK="${AVAILABLE_SHELL}/plugin-manager"
readonly APPS_DIRECTORY="${CONFIG_LINK}/app"
readonly INITIALIZE_SCRIPT_NAME='initialize.sh'
readonly INSTALL_SCRIPT_NAME='install.sh'

readonly has_user_shell_key="${PREFERENCE_ROOT}/has-user-shell-key.sh"
readonly get_user_shell="${PREFERENCE_ROOT}/get-user-shell.sh"
readonly has_user_shell_plugin_manager_key="${PREFERENCE_ROOT}/has-user-shell-plugin-manager-key.sh"
readonly get_user_shell_plugin_manager="${PREFERENCE_ROOT}/get-user-shell-plugin-manager.sh"
readonly has_system_login_shell_plugin_manager_key="${PREFERENCE_ROOT}/has-system-login-shell-plugin-manager-key.sh"
readonly get_system_login_shell_plugin_manager="${PREFERENCE_ROOT}/get-system-login-shell-plugin-manager.sh"
readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make-relative-symlink.sh"

get_shell_plugin_manager_path() {
    printf "${SHELL_DIRECTORY}/${1}/plugin-manager/${2}"
}

if $(${has_user_shell_key}); then
    readonly user_shell=$(${get_user_shell})
    printf 'Initializing user shell.\n'
    if [ ! -L "${AVAILABLE_APPS}/${user_shell}" ]; then
        printf "Install ${user_shell}...\n"
        ${SHELL_DIRECTORY}/${user_shell}/'link'/${INSTALL_SCRIPT_NAME}
        printf "Initialize ${user_shell}...\n"
        ${SHELL_DIRECTORY}/${user_shell}/'link'/${INITIALIZE_SCRIPT_NAME}
        ${make_relative_symlink} "${AVAILABLE_APPS}/${user_shell}" "${APPS_DIRECTORY}/${user_shell}"
    fi
    ${make_relative_symlink} "${AVAILABLE_SHELL_LINK}" "${AVAILABLE_APPS}/${user_shell}"

    if $(${has_user_shell_plugin_manager_key}); then
        readonly user_shell_plugin_manager="$(${get_user_shell_plugin_manager})"
        readonly user_shell_plugin_manager_path="$(get_shell_plugin_manager_path ${user_shell} ${user_shell_plugin_manager})"
        printf "Install ${user_shell_plugin_manager}...\n"
        ${user_shell_plugin_manager_path}/${INSTALL_SCRIPT_NAME}
        printf "Initialize ${user_shell_plugin_manager}...\n"
        ${user_shell_plugin_manager_path}/${INITIALIZE_SCRIPT_NAME}
        ${make_relative_symlink} "${AVAILABLE_APPS}/${user_shell_plugin_manager}" "${APPS_DIRECTORY}/${user_shell_plugin_manager}"
        ${make_relative_symlink} "${AVAILABLE_SHELL_PLUGIN_MANAGER_LINK}" "${AVAILABLE_APPS}/${user_shell_plugin_manager}"
    fi

    printf 'Finish initializing user shell!\n'
else
    printf 'Initializing system login shell.\n'
    readonly system_login_shell_name="$(basename $(readlink ${SYSTEM_LOGIN_SHELL_LINK}))"
    ${SYSTEM_LOGIN_SHELL_LINK}/${INITIALIZE_SCRIPT_NAME}
    ${make_relative_symlink} "${AVAILABLE_APPS}/${system_login_shell_name}" "${APPS_DIRECTORY}/${system_login_shell_name}"
    ${make_relative_symlink} "${AVAILABLE_SHELL_LINK}" "${AVAILABLE_APPS}/${system_login_shell_name}"

    if $(${has_system_login_shell_plugin_manager_key}); then
        readonly system_login_shell_plugin_manager="$(${get_system_login_shell_plugin_manager})"
        readonly system_login_shell_plugin_manager_path="$(get_shell_plugin_manager_path ${system_login_shell_name} ${system_login_shell_plugin_manager})"
        printf "Install ${system_login_shell_plugin_manager}...\n"
        ${system_login_shell_plugin_manager_path}/${INSTALL_SCRIPT_NAME}
        printf "Initialize ${system_login_shell_plugin_manager}...\n"
        ${system_login_shell_plugin_manager_path}/${INITIALIZE_SCRIPT_NAME}
        ${make_relative_symlink} "${AVAILABLE_APPS}/${system_login_shell_plugin_manager}" "${APPS_DIRECTORY}/${system_login_shell_plugin_manager}"
        ${make_relative_symlink} "${AVAILABLE_SHELL_PLUGIN_MANAGER_LINK}" "${AVAILABLE_APPS}/${system_login_shell_plugin_manager}"
    fi

    printf 'Finish initializing system login shell!\n'
fi
