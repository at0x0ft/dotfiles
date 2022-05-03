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
readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make_relative_symlink.sh"

get_shell_plugin_manager_path() {
    printf "${SHELL_DIRECTORY}/${1}/plugin-manager/${2}"
}

# ref: https://github.com/ko1nksm/readlinkf/blob/master/readlinkf.sh
readlinkf() {
    [ "${1:-}" ] || return 1
    max_symlinks=40
    CDPATH='' # to avoid changing to an unexpected directory

    target=$1
    [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
    [ -d "${target:-/}" ] && target="$target/"

    cd -P . 2>/dev/null || return 1
    while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
        if [ ! "$target" = "${target%/*}" ]; then
            case $target in
                /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
                *) cd -P "./${target%/*}" 2>/dev/null || break ;;
            esac
            target=${target##*/}
        fi

        if [ ! -L "$target" ]; then
            target="${PWD%/}${target:+/}${target}"
            printf '%s\n' "${target:-/}"
            return 0
        fi

        # `ls -dl` format: "%s %u %s %s %u %s %s -> %s\n",
        #   <file mode>, <number of links>, <owner name>, <group name>,
        #   <size>, <date and time>, <pathname of link>, <contents of link>
        # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html
        link=$(ls -dl -- "$target" 2>/dev/null) || break
        target=${link#*" $target -> "}
    done
    return 1
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
    readonly system_login_shell_name="$(basename $(readlinkf ${SYSTEM_LOGIN_SHELL_LINK}))"
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
