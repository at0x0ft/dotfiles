#!/usr/bin/env sh
set -e

readonly SCRIPT_PATH="$(
    self=${0}
    while [ -L "${self}" ]; do
        cd "${self%/*}"
        self=$(readlink "${self}")
    done
    cd "${self%/*}"
    echo "$(pwd -P)/${self##*/}"
)"
readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
readonly DOTFILES_SRC_ROOT="$(cd ${SCRIPT_ROOT}/../../..; pwd -P)"
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
readonly ZSHENV_PATH="${HOME}/.zshenv"
readonly INIT_PATH="${SCRIPT_ROOT}/init.zsh"
readonly THEME_PATH="${SCRIPT_ROOT}/theme/rc.zsh"
readonly COMPLETION_PATH="${SCRIPT_ROOT}/completion/rc.zsh"
readonly PLUGIN_PATH="${SCRIPT_ROOT}/plugin/rc.zsh"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly INIT_DIRECTIVE="source '${INIT_PATH}'"
readonly THEME_DIRECTIVE="source '${THEME_PATH}'"
readonly COMPLETION_DIRECTIVE="source '${COMPLETION_PATH}'"
readonly PLUGIN_DIRECTIVE="source '${PLUGIN_PATH}'"
readonly RC_DIRECTIVE="source '${RC_PATH}'"
readonly UBUNTU_SPECIFIC_DIRECTIVE='skip_global_compinit=1'
readonly DEPLOY_SCRIPT_NAME='deploy.sh'

readonly add_directive_to_zshrc="${CURRENT_ROOT}/available/shell/link/external/add-directive.sh"

get_subdir_deploy_scripts() {
    find "${SCRIPT_ROOT}" -mindepth 2 -name "${DEPLOY_SCRIPT_NAME}" -type f
}

for sub_deploy in $(get_subdir_deploy_scripts); do
    ${sub_deploy}
done

printf '%s\n' "${INIT_DIRECTIVE}" >> "${RC_PATH}"
printf '%s\n' "${THEME_DIRECTIVE}" >> "${RC_PATH}"
printf '%s\n' "${COMPLETION_DIRECTIVE}" >> "${RC_PATH}"
printf '%s\n' "${PLUGIN_DIRECTIVE}" >> "${RC_PATH}"

${add_directive_to_zshrc} "${RC_DIRECTIVE}"

readonly get_os_type="${CURRENT_LIBRARY_SCRIPTS}/get-os-type.sh"
if [ "$(${get_os_type})" = 'Ubuntu' ]; then
    printf '%s\n' "${UBUNTU_SPECIFIC_DIRECTIVE}" >> "${ZSHENV_PATH}"
fi
