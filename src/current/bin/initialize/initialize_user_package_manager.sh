#!/usr/bin/env sh
set -eu

initialize_user_package_manager() {
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
  local readonly PACKAGE_MANAGER_DIRECTORY="${CONFIG_LINK}/package_manager"
  local readonly AVAILABLE_USER_PACKAGE_MANAGER="${AVAILABLE_ROOT}/user_package_manager"
  local readonly AVAILABLE_USER_PACKAGE_MANAGER_LINK="${AVAILABLE_USER_PACKAGE_MANAGER}/link"
  local readonly AVAILABLE_USER_PACKAGE_MANAGER_PACKAGES="${AVAILABLE_USER_PACKAGE_MANAGER}/package"
  local readonly APPS_DIRECTORY="${CONFIG_LINK}/app"
  local readonly INITIALIZE_SCRIPT_NAME='initialize.sh'
  local readonly INSTALL_SCRIPT_NAME='install.sh'

  local readonly has_user_package_manager_key="${PREFERENCE_ROOT}/has_user_package_manager_key.sh"
  local readonly get_user_package_manager="${PREFERENCE_ROOT}/get_user_package_manager.sh"
  local readonly has_user_package_manager_package_key="${PREFERENCE_ROOT}/has_user_package_manager_package_key.sh"
  local readonly get_user_package_manager_packages="${PREFERENCE_ROOT}/get_user_package_manager_packages.sh"
  local readonly make_relative_symlink="${LIBRARY_SCRIPTS}/make_relative_symlink.sh"

  if ! $(${has_user_package_manager_key}); then
    return 0
  fi

  printf 'Initializing user package manager.\n'

  local readonly user_package_manager=$(${get_user_package_manager})
  printf 'Install %s...\n' "${user_package_manager}"
  ${PACKAGE_MANAGER_DIRECTORY}/${user_package_manager}/${INSTALL_SCRIPT_NAME}
  printf 'Initialize %s...\n' "${user_package_manager}"
  ${PACKAGE_MANAGER_DIRECTORY}/${user_package_manager}/${INITIALIZE_SCRIPT_NAME}
  ${make_relative_symlink} "${AVAILABLE_APPS}/${user_package_manager}" "${APPS_DIRECTORY}/${user_package_manager}"
  ${make_relative_symlink} "${AVAILABLE_USER_PACKAGE_MANAGER_LINK}" "${AVAILABLE_APPS}/${user_package_manager}"

  if $(${has_user_package_manager_package_key}); then
    printf 'Install packages which install with user package manager.\n'
    for package in $(${get_user_package_manager_packages}); do
      printf 'Install %s...\n' "${package}"
      ${APPS_DIRECTORY}/${package}/${INSTALL_SCRIPT_NAME} "${user_package_manager}"
      printf 'Initialize %s...\n' "${package}"
      ${APPS_DIRECTORY}/${package}/${INITIALIZE_SCRIPT_NAME}
      ${make_relative_symlink} "${AVAILABLE_APPS}/${package}" "${APPS_DIRECTORY}/${package}"
      ${make_relative_symlink} "${AVAILABLE_USER_PACKAGE_MANAGER_PACKAGES}/${package}" "${AVAILABLE_APPS}/${package}"
    done
  fi

  printf 'Finish initializing user package manager!\n'
  return 0
}
initialize_user_package_manager
