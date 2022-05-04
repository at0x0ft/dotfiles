#!/usr/bin/env sh
set -eu

compile() {
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
  local readonly COMPILEDRC_PATH="${SCRIPT_ROOT}/compiled_module_load.zsh"
  local readonly COMPILEDRC_DIRECTIVE="source '${COMPILEDRC_PATH}'"

  local readonly add_directive_to_zshrc_preload="${CURRENT_ROOT}/available/shell/link/rc/preload/add_directive.sh"

  compile() {
    local readonly get_login_shell="${CURRENT_LIBRARY_SCRIPTS}/get_login_shell.sh"
    local readonly login_zsh_shell=$(${get_login_shell})
    ${login_zsh_shell} -i -l -c 'zinit module build; @zinit-scheduler burst || true'
    return 0
  }
  compile

  ${add_directive_to_zshrc_preload} "${COMPILEDRC_DIRECTIVE}"
  return 0
}
compile
