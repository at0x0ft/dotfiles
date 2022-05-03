#!/usr/bin/env sh
set -eu

# ref: https://github.com/Homebrew/install/blob/master/install.sh#L722
get_shellprofile_path() {
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
  local readonly DOTFILES_SRC_ROOT=$(readlinkf "${SCRIPT_ROOT}/../../..")
  local readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
  local readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"

  local readonly get_login_shell="${CURRENT_LIBRARY_SCRIPTS}/get_login_shell.sh"
  local readonly login_shell=$(basename -- $(${get_login_shell}))
  local profile_name
  case "${login_shell}" in
    bash*)
      if [[ -r "${HOME}/.bash_profile" ]]; then
        profile_name='.bash_profile'
      else
        profile_name='.profile'
      fi
      ;;
    zsh*)
      profile_name='.zprofile'
      ;;
    *)
      profile_name='.profile'
      ;;
  esac

  printf '%s/%s' "${HOME}" "${profile_name}"
  return 0
}
get_shellprofile_path
