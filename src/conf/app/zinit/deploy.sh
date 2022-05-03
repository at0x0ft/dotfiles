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
  local readonly DOTFILES_SRC_ROOT=$(readlinkf "${SCRIPT_ROOT}/../../..")
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
  local readonly DEPLOY_SCRIPT_NAME='deploy.sh'

  local readonly add_directive_to_zshrc="${CURRENT_ROOT}/available/shell/link/rc/external/add_directive.sh"
  local readonly add_directive_to_zshenv="${CURRENT_ROOT}/available/shell/link/env/add_directive.sh"

  get_subdir_deploy_scripts() {
    find "${SCRIPT_ROOT}" -mindepth 2 -name "${DEPLOY_SCRIPT_NAME}" -type f
    return 0
  }

  for sub_deploy in $(get_subdir_deploy_scripts); do
    ${sub_deploy}
  done

  printf '%s\n' "${INIT_DIRECTIVE}" >> "${RC_PATH}"
  printf '%s\n' "${THEME_DIRECTIVE}" >> "${RC_PATH}"
  printf '%s\n' "${COMPLETION_DIRECTIVE}" >> "${RC_PATH}"
  printf '%s\n' "${PLUGIN_DIRECTIVE}" >> "${RC_PATH}"

  ${add_directive_to_zshrc} "${RC_DIRECTIVE}"

  local readonly get_os_type="${CURRENT_LIBRARY_SCRIPTS}/get_os_type.sh"
  local readonly os_type=$(${get_os_type})
  if [ "${os_type}" = 'Ubuntu' ]; then
    ${add_directive_to_zshenv} "${UBUNTU_SPECIFIC_DIRECTIVE}"
  fi

  return 0
}
deploy
