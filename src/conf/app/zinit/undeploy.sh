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
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly CURRENT_LIBRARY_SCRIPTS="${CURRENT_ROOT}/lib"
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
readonly UNDEPLOY_SCRIPT_NAME='undeploy.sh'
readonly ZCOMPDUMP_PATH="${HOME}/.zcompdump"
readonly ZINIT_PATH="${HOME}/.zinit"
readonly ZINIT_SRC_PATH_BASENAME='bin'

readonly delete_directive_to_zshrc="${CURRENT_ROOT}/available/shell/link/rc/external/delete-directive.sh"
readonly delete_directive_to_zshenv="${CURRENT_ROOT}/available/shell/link/env/delete-directive.sh"
readonly delete_line="${LIBRARY_SCRIPTS}/delete-line.sh"

get_subdir_undeploy_scripts() {
    find "${SCRIPT_ROOT}" -mindepth 2 -name "${UNDEPLOY_SCRIPT_NAME}" -type f
}

readonly get_os_type="${CURRENT_LIBRARY_SCRIPTS}/get-os-type.sh"
if [ "$(${get_os_type})" = 'Ubuntu' ]; then
    ${delete_directive_to_zshenv} "${UBUNTU_SPECIFIC_DIRECTIVE}"
fi

${delete_directive_to_zshrc} "${RC_DIRECTIVE}"

${delete_line} "${PLUGIN_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${COMPLETION_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${THEME_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${INIT_DIRECTIVE}" "${RC_PATH}"
if [ ! -s "${RC_PATH}" ]; then
    rm "${RC_PATH}"
fi

for sub_undeploy in $(get_subdir_undeploy_scripts); do
    ${sub_undeploy}
done

if [ -f "${ZCOMPDUMP_PATH}" ]; then
    rm -f "${ZCOMPDUMP_PATH}"
fi

for file in $(find ${ZINIT_PATH} -mindepth 1 -maxdepth 1); do
    if [ "$(basename "${file}")" = "${ZINIT_SRC_PATH_BASENAME}" ]; then
        continue
    fi
    rm -rf "${file}"
done
