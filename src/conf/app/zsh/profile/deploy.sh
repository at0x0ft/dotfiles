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
readonly ZPROFILE_PATH="${HOME}/.zprofile"
readonly ZSH_BACKUP_PATH="${CURRENT_ROOT}/bak/zsh"
readonly BACKUP_DST_PATH="${ZSH_BACKUP_PATH}/zprofile"
readonly RC_PATH="${SCRIPT_ROOT}/rc.zsh"
readonly GENERAL_PATH="${SCRIPT_ROOT}/general.zsh"
readonly EXTERNAL_PATH="${SCRIPT_ROOT}/external.zsh"
readonly GENERAL_DIRECTIVE="source '${GENERAL_PATH}'"
readonly EXTERNAL_DIRECTIVE="source '${EXTERNAL_PATH}'"

backup() {
    if [ ! -d "${ZSH_BACKUP_PATH}" ]; then
        mkdir "${ZSH_BACKUP_PATH}"
    fi

    if [ -f "${ZPROFILE_PATH}" -a ! -f "${BACKUP_DST_PATH}" ]; then
        mv "${ZPROFILE_PATH}" "${BACKUP_DST_PATH}"
    fi
}

backup

if [ ! -f "${EXTERNAL_PATH}" ]; then
    touch "${EXTERNAL_PATH}"
fi

printf "${GENERAL_DIRECTIVE}\n" >> "${RC_PATH}"
printf "${EXTERNAL_DIRECTIVE}\n" >> "${RC_PATH}"

ln -snvf "${RC_PATH}" "${ZPROFILE_PATH}"
