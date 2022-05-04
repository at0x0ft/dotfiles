#!/usr/bin/env sh
set -eu

create_preference_link() {
  local readonly environment_type="${1}"
  local readonly preference_path="${2}"

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
  local readonly CURRENT_ROOT=$(readlinkf "${SCRIPT_ROOT}/..")
  local readonly DOTFILES_SRC_ROOT=$(readlinkf "${CURRENT_ROOT}/..")
  local readonly PREFERENCE_SRC_LINK="${SCRIPT_ROOT}/preference.json"
  local readonly get_config_link="${CURRENT_ROOT}/lib/get_config_link.sh"
  local readonly CONFIG_LINK=$(${get_config_link})
  local readonly PREFERENCE_DEFAULT_DST_LINK="${CONFIG_LINK}/preference.json"
  local readonly PREFERENCE_CONTAINER_DST_LINK="${CONFIG_LINK}/preference.container.json"

  local readonly is_container="${CURRENT_ROOT}/lib/is_container.sh"
  local readonly make_relative_symlink="${DOTFILES_SRC_ROOT}/lib/make_relative_symlink.sh"

  get_preference_type() {
    if [ "${preference_path}" != '' ]; then
      printf 'given'
      return 0
    elif [ "${environment_type}" != '' ]; then
      printf '%s' "${environment_type}"
      return 0
    elif $(${is_container}); then
      printf 'container'
      return 0
    else
      printf 'desktop'
      return 0
    fi
  }
  local readonly preference_type=$(get_preference_type)

  if [ "${preference_type}" = 'container' ]; then
    ${make_relative_symlink} "${PREFERENCE_SRC_LINK}" "${PREFERENCE_CONTAINER_DST_LINK}"
  elif [ "${preference_type}" = 'desktop' ]; then
    ${make_relative_symlink} "${PREFERENCE_SRC_LINK}" "${PREFERENCE_DEFAULT_DST_LINK}"
  elif [ "${preference_type}" = 'given' ]; then
    cp "${preference_path}" "${PREFERENCE_SRC_LINK}"
  else
    printf 'Error: Given preference path not found.\n' >&2
    exit 1
  fi

  return 0
}
create_preference_link "${@}"
