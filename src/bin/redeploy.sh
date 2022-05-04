#!/usr/bin/env sh
set -eu

redeploy() {
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
  local readonly SCRIPT_ROOT=$(dirname -- ${SCRIPT_PATH})
  local readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/.."; pwd -P)
  local readonly CURRENT_SCRIPTS="${DOTFILES_SRC_ROOT}/current/bin"

  local readonly decompile="${CURRENT_SCRIPTS}/decompile.sh"
  local readonly undeploy="${CURRENT_SCRIPTS}/undeploy.sh"
  local readonly deploy="${CURRENT_SCRIPTS}/deploy.sh"
  local readonly compile="${CURRENT_SCRIPTS}/compile.sh"


  ${decompile}
  ${undeploy}
  ${deploy}
  ${compile}

  printf 'Now, you should restart shell!\n'
  printf 'ex: exec [your preferred shell] -l\n'
  return 0
}
redeploy
