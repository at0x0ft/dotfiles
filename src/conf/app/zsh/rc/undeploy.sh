#!/usr/bin/env sh
set -e

readonly SCRIPT_PATH=$(
    self=${0}
    while [ -L "${self}" ]; do
        cd "${self%/*}"
        self=$(readlink "${self}")
    done
    cd "${self%/*}"
    echo "$(pwd -P)/${self##*/}"
)
readonly SCRIPT_ROOT="$(dirname ${SCRIPT_PATH})"
readonly DOTFILES_SRC_ROOT=$(cd "${SCRIPT_ROOT}/../../../.."; pwd -P)
readonly CURRENT_ROOT="${DOTFILES_SRC_ROOT}/current"
readonly LIBRARY_SCRIPTS="${DOTFILES_SRC_ROOT}/lib"
readonly ZSHRC_PATH="${HOME}/.zshrc"
readonly ZSH_BACKUP_PATH="${CURRENT_ROOT}/bak/zsh"
readonly BACKUP_DST_PATH="${ZSH_BACKUP_PATH}/zshrc"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly PRELOAD_PATH="${SCRIPT_ROOT}/preload/rc.zsh"
readonly OPT_PATH="${SCRIPT_ROOT}/opt/rc.zsh"
readonly ENVAR_PATH="${SCRIPT_ROOT}/envar/rc.zsh"
readonly KEYBIND_PATH="${SCRIPT_ROOT}/keybind/rc.zsh"
readonly ALIAS_PATH="${SCRIPT_ROOT}/alias/rc.zsh"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external/rc.zsh"
readonly PRELOAD_DIRECTIVE="source '${PRELOAD_PATH}'"
readonly OPT_DIRECTIVE="source '${OPT_PATH}'"
readonly ENVAR_DIRECTIVE="source '${ENVAR_PATH}'"
readonly KEYBIND_DIRECTIVE="source '${KEYBIND_PATH}'"
readonly ALIAS_DIRECTIVE="source '${ALIAS_PATH}'"
readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"
readonly UNDEPLOY_SCRIPT_NAME='deploy.sh'

readonly delete_line="${LIBRARY_SCRIPTS}/delete-line.sh"

restore() {
    if [ -f "${BACKUP_DST_PATH}" ]; then
        mv "${BACKUP_DST_PATH}" "${ZSHRC_PATH}"
    fi

    if [ -d "${ZSH_BACKUP_PATH}" ] && [ -z "$(ls "${ZSH_BACKUP_PATH}")" ]; then
        rmdir "${ZSH_BACKUP_PATH}"
    fi
}

get_subdir_undeploy_scripts() {
    find "${SCRIPT_ROOT}" -mindepth 2 -name "${UNDEPLOY_SCRIPT_NAME}" -type f
}

rm "${ZSHRC_PATH}"

${delete_line} "${EXTERNAL_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${ALIAS_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${KEYBIND_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${ENVAR_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${OPT_DIRECTIVE}" "${RC_PATH}"
${delete_line} "${PRELOAD_DIRECTIVE}" "${RC_PATH}"
if [ ! -s "${RC_PATH}" ]; then
    rm "${RC_PATH}"
fi

for sub_undeploy in $(get_subdir_undeploy_scripts); do
    ${sub_undeploy}
done

restore
