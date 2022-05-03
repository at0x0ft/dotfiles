#!/usr/bin/env sh
set -eu

deploy() {
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
  local readonly ZPROFILE_PATH="${HOME}/.zprofile"
  local readonly ZSH_BACKUP_PATH="${CURRENT_ROOT}/bak/zsh"
  local readonly BACKUP_DST_PATH="${ZSH_BACKUP_PATH}/zprofile"
  local readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
  local readonly GENERAL_PATH="${SCRIPT_ROOT}/general.zsh"
  local readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"
  local readonly GENERAL_DIRECTIVE="source '${GENERAL_PATH}'"
  local readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"

  backup() {
    if [ ! -d "${ZSH_BACKUP_PATH}" ]; then
      mkdir "${ZSH_BACKUP_PATH}"
    fi

    if [ -f "${ZPROFILE_PATH}" -a ! -f "${BACKUP_DST_PATH}" ]; then
      mv "${ZPROFILE_PATH}" "${BACKUP_DST_PATH}"
    fi
    return 0
  }
  backup

  if [ ! -f "${EXTERNAL_PATH}" ]; then
    touch "${EXTERNAL_PATH}"
  fi

  printf '%s\n' "${GENERAL_DIRECTIVE}" >> "${RC_PATH}"
  printf '%s\n' "${EXTERNAL_DIRECTIVE}" >> "${RC_PATH}"

  ln -snvf "${RC_PATH}" "${ZPROFILE_PATH}"

  return 0
}
deploy
