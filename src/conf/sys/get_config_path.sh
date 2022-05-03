#!/usr/bin/env sh
set -eu

get_config_path() {
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

  local readonly UBUNTU_PATH="${SCRIPT_ROOT}/ubuntu"
  local readonly DEBIAN_PATH="${SCRIPT_ROOT}/debian"
  local readonly PENGWIN_PATH="${SCRIPT_ROOT}/pengwin"
  local readonly ALPINE_PATH="${SCRIPT_ROOT}/alpine"
  local readonly DARWIN_PATH="${SCRIPT_ROOT}/darwin"

  not_exist_or_exit() {
    local readonly path="${1}"
    if [ ! -d "${path}" ]; then
      printf 'Error: Corresponding config path (%s) not found.\n' "${path}" >&2
      exit 1
    fi
    return 0
  }

  case "${os_type}" in
    'Ubuntu')
      not_exist_or_exit "${UBUNTU_PATH}"
      printf "${UBUNTU_PATH}"
      ;;
    'Debian'*)
      not_exist_or_exit "${DEBIAN_PATH}"
      printf "${DEBIAN_PATH}"
      ;;
    'Pengwin')
      not_exist_or_exit "${PENGWIN_PATH}"
      printf "${PENGWIN_PATH}"
      ;;
    'Alpine')
      not_exist_or_exit "${ALPINE_PATH}"
      printf "${ALPINE_PATH}"
      ;;
    'Darwin')
      not_exist_or_exit "${DARWIN_PATH}"
      printf "${DARWIN_PATH}"
      ;;
    * )
      printf 'Error: Corresponding config path not matched with OS type: "%s".\n' "${os_type}" >&2
      exit 1
      ;;
  esac
  return 0
}
get_config_path "${@}"
