#!/usr/bin/env sh
set -eu

provisioning() {
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
  local readonly PROVISIONING_SCRIPTS="${SCRIPT_ROOT}/provisioning"

  local readonly get_os_type="${CURRENT_ROOT}/lib/get_os_type.sh"
  local readonly create_config_link="${PROVISIONING_SCRIPTS}/create_config_link.sh"
  local readonly create_preference_link="${CURRENT_ROOT}/pref/create_preference_link.sh"

  printf 'Provisioning...\n'

  printf 'Detecting OS type...\n'
  local readonly os_type=$(${get_os_type})
  printf 'Detected OS type: %s\n' "${os_type}"

  printf 'Creating link to current system config.\n'
  ${create_config_link} "${os_type}"

  printf 'Creating link to preference.\n'
  ${create_preference_link} "${@}"

  # install requirements packages (ex: jq)

  printf 'Provisioning finished!\n'
  return 0
}
provisioning "${@}"
