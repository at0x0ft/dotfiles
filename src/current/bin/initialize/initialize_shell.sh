#!/usr/bin/env sh
set -eu

initialize_shell() {
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

  local readonly SCRIPT_PATH=$(readlinkf "${0}")
  local readonly SCRIPT_ROOT=$(dirname -- "${SCRIPT_PATH}")
  local readonly CURRENT_ROOT=$(readlinkf "${SCRIPT_ROOT}/../..")
  local readonly DOTFILES_SRC_ROOT=$(readlinkf "${CURRENT_ROOT}/..")
  local readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
  local readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
  local readonly PREFERENCE_ROOT="${CURRENT_ROOT}/pref"
  local readonly AVAILABLE_ROOT="${CURRENT_ROOT}/available"
  local readonly AVAILABLE_APPS="${AVAILABLE_ROOT}/app"
  local readonly validate_config_link="${CURRENT_LIBRARY_SCRIPTS}/validate_config_link.sh"
  ${validate_config_link}
  local readonly get_config_link="${CURRENT_LIBRARY_SCRIPTS}/get_config_link.sh"
  local readonly CONFIG_LINK=$(${get_config_link})
  local readonly SHELL_DIRECTORY="${CONFIG_LINK}/shell"
  local readonly SYSTEM_LOGIN_SHELL_LINK="${CONFIG_LINK}/system_login_shell"
  local readonly AVAILABLE_SHELL="${AVAILABLE_ROOT}/shell"
  local readonly AVAILABLE_SHELL_LINK="${AVAILABLE_SHELL}/link"
  local readonly AVAILABLE_SHELL_PLUGIN_MANAGER_LINK="${AVAILABLE_SHELL}/plugin_manager"
  local readonly APPS_DIRECTORY="${CONFIG_LINK}/app"
  local readonly INITIALIZE_SCRIPT_NAME='initialize.sh'
  local readonly INSTALL_SCRIPT_NAME='install.sh'

  local readonly has_user_shell_key="${PREFERENCE_ROOT}/has_user_shell_key.sh"
  local readonly get_user_shell="${PREFERENCE_ROOT}/get_user_shell.sh"
  local readonly has_user_shell_plugin_manager_key="${PREFERENCE_ROOT}/has_user_shell_plugin_manager_key.sh"
  local readonly get_user_shell_plugin_manager="${PREFERENCE_ROOT}/get_user_shell_plugin_manager.sh"
  local readonly has_system_login_shell_plugin_manager_key="${PREFERENCE_ROOT}/has_system_login_shell_plugin_manager_key.sh"
  local readonly get_system_login_shell_plugin_manager="${PREFERENCE_ROOT}/get_system_login_shell_plugin_manager.sh"
  local readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make_relative_symlink.sh"

  install_and_initialize_shell() {
    local readonly shell_name="${1}"
    printf 'Install %s...\n' "${shell_name}"
    ${SHELL_DIRECTORY}/${shell_name}/'link'/${INSTALL_SCRIPT_NAME}
    printf 'Initialize %s...\n' "${shell_name}"
    ${SHELL_DIRECTORY}/${shell_name}/'link'/${INITIALIZE_SCRIPT_NAME}
    ${make_relative_symlink} "${AVAILABLE_APPS}/${shell_name}" "${APPS_DIRECTORY}/${shell_name}"
    return 0
  }

  get_shell_plugin_manager_path() {
    local readonly shell_name="${1}"
    local readonly shell_plugin_manager_name="${2}"
    printf '%s/%s/plugin_manager/%s' "${SHELL_DIRECTORY}" "${shell_name}" "${shell_plugin_manager_name}"
    return 0
  }

  install_and_initialize_shell_plugin_manager() {
    local readonly shell_plugin_manager_path="${1}"
    local readonly shell_plugin_manager_name=$(basename -- "${shell_plugin_manager_path}")
    printf 'Install %s...\n' "${shell_plugin_manager_name}"
    ${shell_plugin_manager_path}/${INSTALL_SCRIPT_NAME}
    printf 'Initialize %s...\n' "${shell_plugin_manager_name}"
    ${shell_plugin_manager_path}/${INITIALIZE_SCRIPT_NAME}
    ${make_relative_symlink} "${AVAILABLE_APPS}/${shell_plugin_manager_name}" "${APPS_DIRECTORY}/${shell_plugin_manager_name}"
    ${make_relative_symlink} "${AVAILABLE_SHELL_PLUGIN_MANAGER_LINK}" "${AVAILABLE_APPS}/${shell_plugin_manager_name}"
    return 0
  }

  initialize_user_shell() {
    printf 'Initializing user shell.\n'
    local readonly user_shell=$(${get_user_shell})

    if [ ! -L "${AVAILABLE_APPS}/${user_shell}" ]; then
      install_and_initialize_shell "${user_shell}"
    fi
    ${make_relative_symlink} "${AVAILABLE_SHELL_LINK}" "${AVAILABLE_APPS}/${user_shell}"

    if $(${has_user_shell_plugin_manager_key}); then
      local readonly user_shell_plugin_manager=$(${get_user_shell_plugin_manager})
      install_and_initialize_shell_plugin_manager $(get_shell_plugin_manager_path "${user_shell}" "${user_shell_plugin_manager}")
    fi

    printf 'Finish initializing user shell!\n'
    return 0
  }

  initialize_system_login_shell() {
    printf 'Initializing system login shell.\n'
    local readonly system_login_shell_name=$(basename -- $(readlinkf "${SYSTEM_LOGIN_SHELL_LINK}"))

    ${SYSTEM_LOGIN_SHELL_LINK}/${INITIALIZE_SCRIPT_NAME}
    ${make_relative_symlink} "${AVAILABLE_APPS}/${system_login_shell_name}" "${APPS_DIRECTORY}/${system_login_shell_name}"
    ${make_relative_symlink} "${AVAILABLE_SHELL_LINK}" "${AVAILABLE_APPS}/${system_login_shell_name}"

    if $(${has_system_login_shell_plugin_manager_key}); then
      local readonly system_login_shell_plugin_manager=$(${get_system_login_shell_plugin_manager})
      install_and_initialize_shell_plugin_manager $(get_shell_plugin_manager_path "${system_login_shell_name}" "${system_login_shell_plugin_manager}")
    fi

    printf 'Finish initializing system login shell!\n'
    return 0
  }

  if $(${has_user_shell_key}); then
    initialize_user_shell
  else
    initialize_system_login_shell
  fi

  return 0
}
initialize_shell
