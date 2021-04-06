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
readonly ZSHRC_PATH="${HOME}/.zshrc"
readonly ZSH_BACKUP_PATH="${CURRENT_ROOT}/bak/zsh"
readonly BACKUP_DST_PATH="${ZSH_BACKUP_PATH}/zshrc"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly PRELOAD_PATH="${SCRIPT_ROOT}/preload/rc.zsh"
readonly ENVAR_PATH="${SCRIPT_ROOT}/envar/rc.zsh"
readonly KEYBIND_PATH="${SCRIPT_ROOT}/keybind/rc.zsh"
readonly ALIAS_PATH="${SCRIPT_ROOT}/alias/rc.zsh"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external/rc.zsh"
readonly PRELOAD_DIRECTIVE="source '${PRELOAD_PATH}'"
readonly ENVAR_DIRECTIVE="source '${ENVAR_PATH}'"
readonly KEYBIND_DIRECTIVE="source '${KEYBIND_PATH}'"
readonly ALIAS_DIRECTIVE="source '${ALIAS_PATH}'"
readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"
readonly DEPLOY_SCRIPT_NAME='deploy.sh'


backup() {
    if [ ! -d "${ZSH_BACKUP_PATH}" ]; then
        mkdir "${ZSH_BACKUP_PATH}"
    fi

    if [ -f "${ZSHRC_PATH}" -a ! -f "${BACKUP_DST_PATH}" ]; then
        mv "${ZSHRC_PATH}" "${BACKUP_DST_PATH}"
    fi
}

get_subdir_deploy_scripts() {
    find "${SCRIPT_ROOT}" -mindepth 2 -name "${DEPLOY_SCRIPT_NAME}" -type f
}

backup

for sub_deploy in $(get_subdir_deploy_scripts); do
    ${sub_deploy}
done

printf "${PRELOAD_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${ENVAR_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${KEYBIND_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${ALIAS_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${EXTERNAL_DIRECTIVE}\n" >> "${RC_PATH}"

ln -snvf "${RC_PATH}" "${ZSHRC_PATH}"
