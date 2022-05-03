#!/usr/bin/env sh
set -eu

remove() {
  local readonly directive_content="${1}"

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
  local readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
  local readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"
  local readonly COMPLETION_BASE_DIRECTIVE='zinit as "completion" \'
  local readonly INDENT='  '

  local readonly delete_line="${LIBRARY_SCRIPTS}/delete_line.sh"

  ${delete_line} "${directive_content}" "${EXTERNAL_PATH}"

  delete_backslash_from_last_line() {
    local readonly file_path="${1}"

    local readonly last_line=$(sed -n $(grep -c '^' "${file_path}")p "${file_path}")
    local readonly last_content="${last_line% \\}"
    local readonly file_temporary_path="/tmp/${file_path}"
    sed -e "s|^${last_content}"' \\'"$|${last_content}|g" "${file_path}" > "${file_temporary_path}"
    mv -f "${file_temporary_path}" "${file_path}"
    return 0
  }
  delete_backslash_from_last_line "${EXTERNAL_PATH}"

  [ $(grep -c '^' "${EXTERNAL_PATH}") -eq 1 ] && rm "${EXTERNAL_PATH}"

  return 0
}
remove "${@}"
