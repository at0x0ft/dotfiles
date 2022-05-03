#!/usr/bin/env sh
set -eu

undeploy() {
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
  local readonly DOTFILES_SRC_ROOT=$(readlinkf "${SCRIPT_ROOT}/../../../..")
  local readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
  local readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
  local readonly ZSHENV_PATH="${HOME}/.zshenv"
  local readonly ZSH_BACKUP_PATH="${CURRENT_ROOT}/bak/zsh"
  local readonly BACKUP_DST_PATH="${ZSH_BACKUP_PATH}/zshenv"
  local readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
  local readonly GENERAL_PATH="${SCRIPT_ROOT}/general.zsh"
  local readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"
  local readonly GENERAL_DIRECTIVE="source '${GENERAL_PATH}'"
  local readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"

  local readonly delete_line="${LIBRARY_SCRIPTS}/delete_line.sh"

  rm "${ZSHENV_PATH}"

  ${delete_line} "${EXTERNAL_DIRECTIVE}" "${RC_PATH}"
  ${delete_line} "${GENERAL_DIRECTIVE}" "${RC_PATH}"
  if [ -e "${RC_PATH}" -a ! -s "${RC_PATH}" ]; then
    rm "${RC_PATH}"
  fi

  restore() {
    if [ -f "${BACKUP_DST_PATH}" ]; then
      mv "${BACKUP_DST_PATH}" "${ZSHENV_PATH}"
    fi

    if [ -d "${ZSH_BACKUP_PATH}" -a -z $(ls "${ZSH_BACKUP_PATH}") ]; then
      rmdir "${ZSH_BACKUP_PATH}"
    fi
    return 0
  }
  restore

  return 0
}
undeploy
