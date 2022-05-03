#!/usr/bin/env sh
set -eu

create_config_link() {
  local readonly os_type="${1}"
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
  local readonly SYSTEM_CONFIG_ROOT=$(readlinkf "${DOTFILES_SRC_ROOT}/conf/sys")
  local readonly get_config_link="${CURRENT_ROOT}/lib/get_config_link.sh"
  local readonly CONFIG_LINK=$(${get_config_link})

  local readonly get_config_path="${SYSTEM_CONFIG_ROOT}/get_config_path.sh"
  local readonly make_relative_symlink="${DOTFILES_SRC_ROOT}/lib/make_relative_symlink.sh"

  ${make_relative_symlink} "${CONFIG_LINK}" $(${get_config_path} "${os_type}")

  return 0
}
create_config_link "${@}"
