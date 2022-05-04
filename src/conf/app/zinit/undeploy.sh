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
  local readonly SCRIPT_ROOT=$(dirname -- ${SCRIPT_PATH})
  local readonly DOTFILES_SRC_ROOT=$(readlinkf "${SCRIPT_ROOT}/../../..")
  local readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
  local readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
  local readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
  local readonly INIT_PATH="${SCRIPT_ROOT}/init.zsh"
  local readonly THEME_PATH="${SCRIPT_ROOT}/theme/rc.zsh"
  local readonly COMPLETION_PATH="${SCRIPT_ROOT}/completion/rc.zsh"
  local readonly PLUGIN_PATH="${SCRIPT_ROOT}/plugin/rc.zsh"
  local readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
  local readonly INIT_DIRECTIVE="source '${INIT_PATH}'"
  local readonly THEME_DIRECTIVE="source '${THEME_PATH}'"
  local readonly COMPLETION_DIRECTIVE="source '${COMPLETION_PATH}'"
  local readonly PLUGIN_DIRECTIVE="source '${PLUGIN_PATH}'"
  local readonly RC_DIRECTIVE="source '${RC_PATH}'"
  local readonly UBUNTU_SPECIFIC_DIRECTIVE='skip_global_compinit=1'
  local readonly UNDEPLOY_SCRIPT_NAME='undeploy.sh'
  local readonly ZCOMPDUMP_PATH="${HOME}/.zcompdump"
  local readonly ZINIT_PATH="${HOME}/.local/share/zinit"
  local readonly ZINIT_SRC_PATH_BASENAME='zinit.git'

  local readonly delete_directive_to_zshrc="${CURRENT_ROOT}/available/shell/link/rc/external/delete_directive.sh"
  local readonly delete_directive_to_zshenv="${CURRENT_ROOT}/available/shell/link/env/delete_directive.sh"
  local readonly delete_line="${LIBRARY_SCRIPTS}/delete_line.sh"

  get_subdir_undeploy_scripts() {
    find "${SCRIPT_ROOT}" -mindepth 2 -name "${UNDEPLOY_SCRIPT_NAME}" -type f
    return 0
  }

  local readonly get_os_type="${CURRENT_LIBRARY_SCRIPTS}/get_os_type.sh"
  local readonly os_type=$(${get_os_type})
  if [ "${os_type}" = 'Ubuntu' ]; then
    ${delete_directive_to_zshenv} "${UBUNTU_SPECIFIC_DIRECTIVE}"
  fi

  ${delete_directive_to_zshrc} "${RC_DIRECTIVE}"

  ${delete_line} "${PLUGIN_DIRECTIVE}" "${RC_PATH}"
  ${delete_line} "${COMPLETION_DIRECTIVE}" "${RC_PATH}"
  ${delete_line} "${THEME_DIRECTIVE}" "${RC_PATH}"
  ${delete_line} "${INIT_DIRECTIVE}" "${RC_PATH}"
  if [ -e "${RC_PATH}" -a ! -s "${RC_PATH}" ]; then
    rm "${RC_PATH}"
  fi

  for sub_undeploy in $(get_subdir_undeploy_scripts); do
    ${sub_undeploy}
  done

  if [ -f "${ZCOMPDUMP_PATH}" ]; then
    rm -f "${ZCOMPDUMP_PATH}"
  fi

  for file in $(find ${ZINIT_PATH} -mindepth 1 -maxdepth 1); do
    if [ $(basename "${file}") = "${ZINIT_SRC_PATH_BASENAME}" ]; then
      continue
    fi
    rm -rf "${file}"
  done

  return 0
}
undeploy
